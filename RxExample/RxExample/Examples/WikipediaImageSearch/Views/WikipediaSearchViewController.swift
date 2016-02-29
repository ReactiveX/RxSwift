//
//  WikipediaSearchViewController.swift
//  Example
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
    
    private var resultsTableView: UITableView {
        return self.searchDisplayController!.searchResultsTableView
    }

    private var searchBar: UISearchBar {
        return self.searchDisplayController!.searchBar
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableDataSource()
        configureKeyboardDismissesOnScroll()
        configureNavigateOnRowClick()
        configureActivityIndicatorsShow()
    }

    func configureTableDataSource() {
        resultsTableView.registerNib(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        
        resultsTableView.rowHeight = 194

        let API = DefaultWikipediaAPI.sharedAPI

        searchBar.rx_text
            .asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
            .flatMapLatest { query in
                API.getSearchResults(query)
                    .retry(3)
                    .retryOnBecomesReachable([], reachabilityService: ReachabilityService.sharedReachabilityService)
                    .startWith([]) // clears results on new search term
                    .asDriver(onErrorJustReturn: [])
            }
            .map { results in
                results.map(SearchResultViewModel.init)
            }
            .drive(resultsTableView.rx_itemsWithCellIdentifier("WikipediaSearchCell", cellType: WikipediaSearchCell.self)) { (_, viewModel, cell) in
                cell.viewModel = viewModel
            }
            .addDisposableTo(disposeBag)
    }

    func configureKeyboardDismissesOnScroll() {
        let searchBar = self.searchBar

        resultsTableView.rx_contentOffset
            .asDriver()
            .driveNext { _ in
                if searchBar.isFirstResponder() {
                    _ = searchBar.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)
    }

    func configureNavigateOnRowClick() {
        let wireframe = DefaultWireframe.sharedInstance

        resultsTableView.rx_modelSelected(SearchResultViewModel.self)
            .asDriver()
            .driveNext { searchResult in
                wireframe.openURL(searchResult.searchResult.URL)
            }
            .addDisposableTo(disposeBag)
    }

    func configureActivityIndicatorsShow() {
        Driver.combineLatest(
            DefaultWikipediaAPI.sharedAPI.loadingWikipediaData,
            DefaultImageService.sharedImageService.loadingImage
        ) { $0 || $1 }
            .distinctUntilChanged()
            .drive(UIApplication.sharedApplication().rx_networkActivityIndicatorVisible)
            .addDisposableTo(disposeBag)
    }
}
