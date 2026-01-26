//
//  GitHubSearchRepositoriesViewController.swift
//  RxExample
//
//  Created by Yoshinori Sano on 9/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        contentOffset.y + frame.size.height + edgeOffset > contentSize.height
    }
}

class GitHubSearchRepositoriesViewController: ViewController, UITableViewDelegate {
    static let startLoadingOffset: CGFloat = 20.0

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!

    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>(
        configureCell: { (_, tv, _, repository: Repository) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.url.absoluteString
            return cell
        },
        titleForHeaderInSection: { dataSource, sectionIndex in
            let section = dataSource[sectionIndex]
            return section.items.count > 0 ? "Repositories (\(section.items.count))" : "No repositories found"
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView: UITableView = tableView
        let loadNextPageTrigger: (Driver<GitHubSearchRepositoriesState>) -> Signal<Void> = { state in
            tableView.rx.contentOffset.asDriver()
                .withLatestFrom(state)
                .flatMap { state in
                    tableView.isNearBottomEdge(edgeOffset: 20.0) && !state.shouldLoadNextPage
                        ? Signal.just(())
                        : Signal.empty()
                }
        }

        let activityIndicator = ActivityIndicator()

        let searchBar: UISearchBar = searchBar

        let state = githubSearchRepositories(
            searchText: searchBar.rx.text.orEmpty.changed.asSignal().throttle(.milliseconds(300)),
            loadNextPageTrigger: loadNextPageTrigger,
            performSearch: { URL in
                GitHubSearchRepositoriesAPI.sharedAPI.loadSearchURL(URL)
                    .trackActivity(activityIndicator)
            }
        )

        state
            .map(\.isOffline)
            .drive(navigationController!.rx.isOffline)
            .disposed(by: disposeBag)

        state
            .map(\.repositories)
            .distinctUntilChanged()
            .map { [SectionModel(model: "Repositories", items: $0.value)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Repository.self)
            .subscribe(onNext: { repository in
                UIApplication.shared.open(repository.url)
            })
            .disposed(by: disposeBag)

        state
            .map(\.isLimitExceeded)
            .distinctUntilChanged()
            .filter(\.self)
            .drive(onNext: { [weak self] _ in
                guard let self else { return }

                let message = "Exceeded limit of 10 non authenticated requests per minute for GitHub API. Please wait a minute. :(\nhttps://developer.github.com/v3/#rate-limiting"

                #if os(iOS)
                present(UIAlertController(title: "RxExample", message: message, preferredStyle: .alert), animated: true)
                #elseif os(macOS)
                let alert = NSAlert()
                alert.messageText = message
                alert.runModal()
                #endif
            })
            .disposed(by: disposeBag)

        tableView.rx.contentOffset
            .subscribe { _ in
                if searchBar.isFirstResponder {
                    _ = searchBar.resignFirstResponder()
                }
            }
            .disposed(by: disposeBag)

        // so normal delegate customization can also be used
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        // activity indicator in status bar
        // {
        activityIndicator
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        // }
    }

    // MARK: Table view delegate

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        30
    }

    deinit {
        // I know, I know, this isn't a good place of truth, but it's no
        self.navigationController?.navigationBar.backgroundColor = nil
    }
}
