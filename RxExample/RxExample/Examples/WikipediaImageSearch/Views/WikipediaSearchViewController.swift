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
    
    
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        let searchBar = searchController.searchBar
        
        tableView.registerNib(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        
        tableView.rowHeight = 194
        
        let selectedResult: Observable<SearchResultViewModel> = tableView.rx_modelSelected()
        
        let viewModel = SearchViewModel(
            searchText: searchBar.rx_searchText,
            selectedResult: selectedResult
        )
        
        // map table view rows
        // {
        viewModel.rows
            .subscribeItemsOf(tableView, withCellIdentifier: "WikipediaSearchCell") { (_, viewModel, cell: WikipediaSearchCell) in
                cell.viewModel = viewModel
            }
            .addDisposableTo(disposeBag)
        // }

        // dismiss keyboard on scroll
        // {
        tableView.rx_contentOffset
            .subscribeNext { _ in
                if searchBar.isFirstResponder() {
                    _ = searchBar.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)

        self.viewModel = viewModel
        // }
    }
}
