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
        
        let viewModel = SearchViewModel(
            searchText: searchBar.rx_text.asDriver(),
            selectedResult: resultsTableView.rx_modelSelected().asDriver()
        )
        
        // map table view rows
        // {
        viewModel.rows
            .drive(resultsTableView.rx_itemsWithCellIdentifier("WikipediaSearchCell")) { (_, viewModel, cell: WikipediaSearchCell) in
                cell.viewModel = viewModel
            }
            .addDisposableTo(disposeBag)
        // }

        // dismiss keyboard on scroll
        // {
        resultsTableView.rx_contentOffset
            .asDriver()
            .driveNext { _ in
                if searchBar.isFirstResponder() {
                    _ = searchBar.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)

        self.viewModel = viewModel
        // }

        // activity indicator spinner
        // {
        combineLatest(
            DefaultWikipediaAPI.sharedAPI.loadingWikipediaData,
            DefaultImageService.sharedImageService.loadingImage
        ) { $0 || $1 }
            .distinctUntilChanged()
            .driveNext { active in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = active
            }
            .addDisposableTo(disposeBag)
        // }
    }
}
