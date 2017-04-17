//
//  WikipediaSearchViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class WikipediaSearchViewController: ViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var resultsTableView: UITableView!
    @IBOutlet var emptyView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = .all

        configureTableDataSource()
        configureKeyboardDismissesOnScroll()
        configureNavigateOnRowClick()
        configureActivityIndicatorsShow()
    }

    func configureTableDataSource() {
        resultsTableView.register(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        
        resultsTableView.rowHeight = 194
        resultsTableView.hideEmptyCells()

        // This is for clarity only, don't use static dependencies
        let API = DefaultWikipediaAPI.sharedAPI

        let results = searchBar.rx.text.orEmpty
            .asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
            .flatMapLatest { query in
                API.getSearchResults(query)
                    .retry(3)
                    .retryOnBecomesReachable([], reachabilityService: Dependencies.sharedDependencies.reachabilityService)
                    .startWith([]) // clears results on new search term
                    .asDriver(onErrorJustReturn: [])
            }
            .map { results in
                results.map(SearchResultViewModel.init)
            }

        results
            .drive(resultsTableView.rx.items(cellIdentifier: "WikipediaSearchCell", cellType: WikipediaSearchCell.self)) { (_, viewModel, cell) in
                cell.viewModel = viewModel
            }
            .disposed(by: disposeBag)

        results
            .map { $0.count != 0 }
            .drive(self.emptyView.rx.isHidden)
            .disposed(by: disposeBag)
    }

    func configureKeyboardDismissesOnScroll() {
        let searchBar = self.searchBar
        
        resultsTableView.rx.contentOffset
            .asDriver()
            .drive(onNext: { _ in
                if searchBar?.isFirstResponder ?? false {
                    _ = searchBar?.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }

    func configureNavigateOnRowClick() {
        let wireframe = DefaultWireframe.shared

        resultsTableView.rx.modelSelected(SearchResultViewModel.self)
            .asDriver()
            .drive(onNext: { searchResult in
                wireframe.open(url:searchResult.searchResult.URL)
            })
            .disposed(by: disposeBag)
    }

    func configureActivityIndicatorsShow() {
        Driver.combineLatest(
            DefaultWikipediaAPI.sharedAPI.loadingWikipediaData,
            DefaultImageService.sharedImageService.loadingImage
        ) { $0 || $1 }
            .distinctUntilChanged()
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
    }
}
