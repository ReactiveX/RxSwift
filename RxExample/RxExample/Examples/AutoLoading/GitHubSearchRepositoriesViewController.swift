//
//  GitHubSearchRepositoriesViewController.swift
//  RxExample
//
//  Created by Yoshinori Sano on 9/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class GitHubSearchRepositoriesViewController: ViewController, UITableViewDelegate {
    static let startLoadingOffset: CGFloat = 20.0

    static func isNearTheBottomEdge(contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
    }

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var disposeBag = DisposeBag()
    let repositories = Variable([Repository]())
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let $: Dependencies = Dependencies.sharedDependencies

        let tableView = self.tableView
        let searchBar = self.searchBar

        let allRepositories = repositories
            .map { repositories in
                return [SectionModel(model: "Repositories", items: repositories)]
            }

        dataSource.cellFactory = { (tv, ip, repository: Repository) in
            let cell = tv.dequeueReusableCellWithIdentifier("Cell")!
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.url
            return cell
        }

        dataSource.titleForHeaderInSection = { [unowned dataSource] sectionIndex in
            let section = dataSource.sectionAtIndex(sectionIndex)
            return section.items.count > 0 ? "Repositories (\(section.items.count))" : "No repositories found"
        }

        // reactive data source
        allRepositories
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)

        let loadNextPageTrigger = tableView.rx_contentOffset
            .flatMap { offset in
                GitHubSearchRepositoriesViewController.isNearTheBottomEdge(offset, tableView)
                    ? just()
                    : empty()
            }

        searchBar.rx_text
            .throttle(0.3, $.mainScheduler)
            .distinctUntilChanged()
            .map { query -> Observable<SearchRepositoryResponse> in
                if query.isEmpty {
                    return just(.Repositories([]))
                } else {
                    return GitHubSearchRepositoriesAPI.sharedAPI.search(query, loadNextPageTrigger: loadNextPageTrigger)
                        .catchErrorJustReturn(.Repositories([]))
                }
            }
            .switchLatest()
            .subscribeNext { [unowned self] result in
                switch result {
                case .Repositories(let repositories):
                    self.repositories.value = repositories
                case .LimitExceeded:
                    self.repositories.value = []
                    showAlert("Exceeded limit of 10 non authenticated requests per minute for GitHub API. Please wait a minute. :(\nhttps://developer.github.com/v3/#rate-limiting")
                }
            }
            .addDisposableTo(disposeBag)

        // dismiss keyboard on scroll
        tableView.rx_contentOffset
            .subscribe { _ in
                if searchBar.isFirstResponder() {
                    _ = searchBar.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)

        // so normal delegate customization can also be used
        tableView.rx_setDelegate(self)
            .addDisposableTo(disposeBag)

        // activity indicator in status bar
        // {
        GitHubSearchRepositoriesAPI.sharedAPI.activityIndicator
            .distinctUntilChanged()
            .driveNext { active in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = active
            }
            .addDisposableTo(disposeBag)
        // }
    }

    // MARK: Table view delegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
