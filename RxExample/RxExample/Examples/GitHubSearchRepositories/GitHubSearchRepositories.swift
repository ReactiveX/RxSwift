//
//  GitHubSearchRepositories.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 3/18/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

enum GitHubCommand {
    case changeSearch(text: String)
    case loadMoreItems
    case gitHubResponseReceived(SearchRepositoriesResponse)
}

struct GitHubSearchRepositoriesState {
    // control
    var searchText: String
    var shouldLoadNextPage: Bool
    var repositories: [Repository]
    var nextURL: URL?
    var failure: GitHubServiceError?

    init(searchText: String) {
        self.searchText = searchText
        shouldLoadNextPage = true
        repositories = []
        nextURL = URL(string: "https://api.github.com/search/repositories?q=\(searchText.URLEscaped)")
        failure = nil
    }
}

extension GitHubSearchRepositoriesState {
    static let initial = GitHubSearchRepositoriesState(searchText: "")

    static func reduce(state: GitHubSearchRepositoriesState, command: GitHubCommand) -> GitHubSearchRepositoriesState {
        switch command {
        case .changeSearch(let text):
            var new = GitHubSearchRepositoriesState(searchText: text)
            new.failure = state.failure
            return new
        case .gitHubResponseReceived(let result):
            switch result {
            case let .success((repositories, nextURL)):
                var new = state
                new.repositories += repositories
                new.shouldLoadNextPage = false
                new.nextURL = nextURL
                new.failure = nil
                return new
            case let .failure(error):
                var new = state
                new.failure = error
                return new
            }
        case .loadMoreItems:
            var new = state
            if new.failure == nil {
                new.shouldLoadNextPage = true
            }
            return new
        }
    }
}

import RxSwift
import RxCocoa

/**
 This method contains the gist of paginated GitHub search.
 
 */
func githubSearchRepositories(
        searchText: Driver<String>,
        loadNextPageTrigger: Driver<()>,
        performSearch: @escaping (URL) -> Observable<SearchRepositoriesResponse>
    ) -> Driver<GitHubSearchRepositoriesState> {

    let searchPerformerFeedback: (Driver<GitHubSearchRepositoriesState>) -> Driver<GitHubCommand> = { state in
        // this is a general pattern how to model a most common feedback loop
        // first select part of state describing feedback control
        return state.map { (searchText: $0.searchText, shouldLoadNextPage: $0.shouldLoadNextPage, nextURL: $0.nextURL) }
            // only propagate changed control values since there could be multiple feedback loops working in parallel
            .distinctUntilChanged { $0 == $1 }
            // perform feedback loop effects
            .flatMapLatest { (searchText, shouldLoadNextPage, nextURL) -> Driver<GitHubCommand> in
                if !shouldLoadNextPage {
                    return Driver.empty()
                }

                if searchText.isEmpty {
                    return Driver.just(GitHubCommand.gitHubResponseReceived(.success(repositories: [], nextURL: nil)))
                }

                guard let nextURL = nextURL else {
                    return Driver.empty()
                }

                return performSearch(nextURL)
                    .asDriver(onErrorJustReturn: .failure(GitHubServiceError.networkError))
                    .map(GitHubCommand.gitHubResponseReceived)
            }
    }

    // this is degenerated feedback loop that doesn't depend on output state
    let inputFeedbackLoop: (Driver<GitHubSearchRepositoriesState>) -> Driver<GitHubCommand> = { _ in
        let loadNextPage = loadNextPageTrigger.map { _ in GitHubCommand.loadMoreItems }
        let searchText = searchText.map(GitHubCommand.changeSearch)

        return Driver.merge(loadNextPage, searchText)
    }

    // Create a system with two feedback loops that drive the system
    // * one that tries to load new pages when necessary
    // * one that sends commands from user input
    return Driver.system(GitHubSearchRepositoriesState.initial,
                         accumulator: GitHubSearchRepositoriesState.reduce,
                         feedback: searchPerformerFeedback, inputFeedbackLoop)
}

func == (
        lhs: (searchText: String, shouldLoadNextPage: Bool, nextURL: URL?),
        rhs: (searchText: String, shouldLoadNextPage: Bool, nextURL: URL?)
    ) -> Bool {
    return lhs.searchText == rhs.searchText
        && lhs.shouldLoadNextPage == rhs.shouldLoadNextPage
        && lhs.nextURL == rhs.nextURL
}

extension GitHubSearchRepositoriesState {
    var isOffline: Bool {
        guard let failure = self.failure else {
            return false
        }

        if case .offline = failure {
            return true
        }
        else {
            return false
        }
    }

    var isLimitExceeded: Bool {
        guard let failure = self.failure else {
            return false
        }

        if case .githubLimitReached = failure {
            return true
        }
        else {
            return false
        }
    }
}
