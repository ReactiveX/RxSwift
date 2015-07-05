//
//  ViewController.swift
//  Example
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WikipediaSearchViewController: ViewController {
    
    private var disposeBag = DisposeBag()
    private var viewModel: SearchViewModel? = nil
    
    @IBOutlet weak var tv: UITableView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let resultsTableView = self.searchDisplayController!.searchResultsTableView
        let searchBar = self.searchDisplayController!.searchBar
        
        resultsTableView.registerNib(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        tv!.registerNib(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        
        resultsTableView.rowHeight = 194
        
        let selectedResult: Observable<SearchResultViewModel> = resultsTableView.rx_modelSelected()
        
        let viewModel = SearchViewModel(
            searchText: searchBar.rx_searchText,
            selectedResult: selectedResult
        )
        
        /*let sectionedDs = RxTableViewSectionedReloadDataSource<SectionModel<String, WikipediaSearchResult>>()
        sectionedDs.cellFactory = { (tv, ip, viewModel) in
            let cell = tv.dequeueReusableCellWithIdentifier("WikipediaSearchCell", forIndexPath: ip) as! WikipediaSearchCell
            //cell.viewModel = viewModel
            return cell
        }
    
        let results: Observable<[SectionModel<String, WikipediaSearchResult>]> = just([])
        
        results
            >- tv!.rx_subscribeWithReactiveDataSource(sectionedDs)
            >- disposeBag.addDisposable
        results
            >- tv.rx_subscribeItemsToWithCellIdentifier("WikipediaSearchCell") { (_, viewModel, cell: WikipediaSearchCell) in
                cell.viewModel = viewModel
            }
            >- disposeBag.addDisposable
        
        */
        

        
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
