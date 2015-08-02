//
//  ViewController.swift
//  Example
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class WikipediaSearchViewController: ViewController {
    
    private var disposeBag = DisposeBag()
    private var viewModel: SearchViewModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let resultsTableView = self.searchDisplayController!.searchResultsTableView
        let searchBar = self.searchDisplayController!.searchBar
        
        resultsTableView.registerNib(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        
        resultsTableView.rowHeight = 194
        
        let selectedResult: Observable<SearchResultViewModel> = resultsTableView.rx_modelSelected()
        
        let viewModel = SearchViewModel(
            searchText: searchBar.rx_searchText,
            selectedResult: selectedResult
        )
        
        // map table view rows
        // {
        viewModel.rows
            >- resultsTableView.rx_subscribeItemsToWithCellIdentifier("WikipediaSearchCell") { (_, viewModel, cell: WikipediaSearchCell) in
                cell.viewModel = viewModel
            }
            >- disposeBag.addDisposable
        // }

        // dismiss keyboard on scroll
        // {
        resultsTableView.rx_contentOffset
            >- subscribeNext { _ in
                if searchBar.isFirstResponder() {
                    _ = searchBar.resignFirstResponder()
                }
            }
            >- disposeBag.addDisposable

        disposeBag.addDisposable(viewModel)
        
        self.viewModel = viewModel
        // }
    }
}