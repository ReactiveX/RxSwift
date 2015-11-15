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

struct Colors {
    static let OfflineColor = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
    static let OnlineColor = nil as UIColor?
}

extension UINavigationController {
    var rx_serviceState: AnyObserver<ServiceState?> {
        return AnyObserver { event in
            switch event {
            case .Next(let maybeServiceState):
                // if nil is being bound, then don't change color, it's not perfect, but :)
                if let serviceState = maybeServiceState {
                    let isOffline = serviceState ?? .Online == .Offline

                    self.navigationBar.backgroundColor = isOffline
                        ? Colors.OfflineColor
                        : Colors.OnlineColor
                }
            case .Error(let error):
                bindingErrorToInterface(error)
            case .Completed:
                break
            }
        }
    }
}

class GitHubSearchRepositoriesViewController: ViewController, UITableViewDelegate {
    static let startLoadingOffset: CGFloat = 20.0

    static func isNearTheBottomEdge(contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var disposeBag = DisposeBag()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let $: Dependencies = Dependencies.sharedDependencies

        let tableView = self.tableView
        let searchBar = self.searchBar

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


        let loadNextPageTrigger = tableView.rx_contentOffset
            .flatMap { offset in
                GitHubSearchRepositoriesViewController.isNearTheBottomEdge(offset, tableView)
                    ? just()
                    : empty()
            }

        let searchResult = searchBar.rx_text.asDriver()
            .throttle(0.3, $.mainScheduler)
            .distinctUntilChanged()
            .flatMapLatest { query -> Driver<RepositoriesState> in
                if query.isEmpty {
                    return Drive.just(RepositoriesState.empty)
                } else {
                    return GitHubSearchRepositoriesAPI.sharedAPI.search(query, loadNextPageTrigger: loadNextPageTrigger)
                        .asDriver(onErrorJustReturn: RepositoriesState.empty)
                }
            }

        searchResult
            .map { $0.serviceState }
            .drive(navigationController!.rx_serviceState)
            .addDisposableTo(disposeBag)

        searchResult
            .map { [SectionModel(model: "Repositories", items: $0.repositories)] }
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)

        searchResult
            .flatMap { $0.limitExceeded ? Drive.just() : Drive.empty() }
            .driveNext { n in
                showAlert("Exceeded limit of 10 non authenticated requests per minute for GitHub API. Please wait a minute. :(\nhttps://developer.github.com/v3/#rate-limiting") 
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

    deinit {
        // I know, I know, this isn't a good place of truth, but it's no
        self.navigationController?.navigationBar.backgroundColor = nil
    }
}
