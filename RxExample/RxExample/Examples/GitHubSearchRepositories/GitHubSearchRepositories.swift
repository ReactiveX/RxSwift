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
    var repositories: Version<[Repository]> // Version is an optimization. When something unrelated changes, we don't want to reload table view.
    var nextURL: URL?
    var failure: GitHubServiceError?

    init(searchText: String) {
        self.searchText = searchText
        shouldLoadNextPage = true
        repositories = Version([])
        nextURL = URL(string: "https://api.github.com/search/repositories?q=\(searchText.URLEscaped)")
        failure = nil
    }
}

extension GitHubSearchRepositoriesState {
    static let initial = GitHubSearchRepositoriesState(searchText: "")

    static func reduce(state: GitHubSearchRepositoriesState, command: GitHubCommand) -> GitHubSearchRepositoriesState {
        switch command {
        case .changeSearch(let text):
            return GitHubSearchRepositoriesState(searchText: text).mutateOne { $0.failure = state.failure }
        case .gitHubResponseReceived(let result):
            switch result {
            case let .success((repositories, nextURL)):
                return state.mutate {
                    $0.repositories = Version($0.repositories.value + repositories)
                    $0.shouldLoadNextPage = false
                    $0.nextURL = nextURL
                    $0.failure = nil
                }
            case let .failure(error):
                return state.mutateOne { $0.failure = error }
            }
        case .loadMoreItems:
            return state.mutate {
                if $0.failure == nil {
                    $0.shouldLoadNextPage = true
                }
            }
        }
    }
}

import RxSwift
import RxCocoa

/**
 This method contains the gist of paginated GitHub search.
 
 */
func githubSearchRepositories(
        searchText: Signal<String>,
        loadNextPageTrigger: @escaping (Driver<GitHubSearchRepositoriesState>) -> Signal<()>,
        performSearch: @escaping (URL) -> Observable<SearchRepositoriesResponse>
    ) -> Driver<GitHubSearchRepositoriesState> {

    let searchPerformerFeedback: (Driver<GitHubSearchRepositoriesState>) -> Signal<GitHubCommand> = react(
        query: { (searchText: $0.searchText, shouldLoadNextPage: $0.shouldLoadNextPage, nextURL: $0.nextURL) },
        effects: { query -> Signal<GitHubCommand> in
                if !query.shouldLoadNextPage {
                    return Signal.empty()
                }

                if query.searchText.isEmpty {
                    return Signal.just(GitHubCommand.gitHubResponseReceived(.success((repositories: [], nextURL: nil))))
                }

                guard let nextURL = query.nextURL else {
                    return Signal.empty()
                }

                return performSearch(nextURL)
                    .asSignal(onErrorJustReturn: .failure(GitHubServiceError.networkError))
                    .map(GitHubCommand.gitHubResponseReceived)
            }
    )

    // this is degenerated feedback loop that doesn't depend on output state
    let inputFeedbackLoop: (Driver<GitHubSearchRepositoriesState>) -> Signal<GitHubCommand> = { state in
        let loadNextPage = loadNextPageTrigger(state).map { _ in GitHubCommand.loadMoreItems }
        let searchText = searchText.map(GitHubCommand.changeSearch)

        return Signal.merge(loadNextPage, searchText)
    }

    // Create a system with two feedback loops that drive the system
    // * one that tries to load new pages when necessary
    // * one that sends commands from user input
    return Driver.system(
        initialState: GitHubSearchRepositoriesState.initial,
        reduce: GitHubSearchRepositoriesState.reduce,
        feedback: searchPerformerFeedback, inputFeedbackLoop
    )
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

extension GitHubSearchRepositoriesState: Mutable {

}
