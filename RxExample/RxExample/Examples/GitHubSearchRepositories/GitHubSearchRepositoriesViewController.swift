//
//  GitHubSearchRepositoriesViewController.swift
//  RxExample
//
//  Created by Yoshinori Sano on 9/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}

class GitHubSearchRepositoriesViewController: ViewController, UITableViewDelegate {
    static let startLoadingOffset: CGFloat = 20.0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.configureCell = { (_, tv, ip, repository: Repository) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.url
            return cell
        }

        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            let section = dataSource[sectionIndex]
            return section.items.count > 0 ? "Repositories (\(section.items.count))" : "No repositories found"
        }


        let tableView: UITableView = self.tableView
        let loadNextPageTrigger = self.tableView.rx.contentOffset
            .flatMap { _ in
                return tableView.isNearBottomEdge(edgeOffset: 20.0)
                    ? Observable.just(())
                    : Observable.empty()
            }

        let searchResult = self.searchBar.rx.text.orEmpty.asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
            .flatMapLatest { query -> Driver<RepositoriesState> in
                if query.isEmpty {
                    return Driver.just(RepositoriesState.empty)
                } else {
                    return GitHubSearchRepositoriesAPI.sharedAPI.search(query, loadNextPageTrigger: loadNextPageTrigger)
                        .asDriver(onErrorJustReturn: RepositoriesState.empty)
                }
            }

        searchResult
            .map { $0.serviceState }
            .drive(navigationController!.rx.serviceState)
            .disposed(by: disposeBag)

        searchResult
            .map { [SectionModel(model: "Repositories", items: $0.repositories)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        searchResult
            .filter { $0.limitExceeded }
            .drive(onNext: { n in
                showAlert("Exceeded limit of 10 non authenticated requests per minute for GitHub API. Please wait a minute. :(\nhttps://developer.github.com/v3/#rate-limiting") 
            })
            .disposed(by: disposeBag)

        let searchBar: UISearchBar = self.searchBar
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
        GitHubSearchRepositoriesAPI.sharedAPI.activityIndicator
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        // }
    }

    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    deinit {
        // I know, I know, this isn't a good place of truth, but it's no
        self.navigationController?.navigationBar.backgroundColor = nil
    }
}
