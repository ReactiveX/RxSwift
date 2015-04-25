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
    
    private let disposeBag: DisposeBag = DisposeBag()
    private var viewModel: SearchViewModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = NSQualityOfService.UserInitiated
        
        let backgroundScheduler = OperationQueueScheduler(operationQueue: operationQueue)
        let mainScheduler = MainScheduler.sharedInstance
        
        weak var weakSelf = self
        
        let API = DefaultWikipediaAPI($: (
            URLSession: NSURLSession.sharedSession(),
            callbackScheduler: mainScheduler,
            backgroundScheduler: backgroundScheduler
        ))
        let imageService = DefaultImageService($: (
            URLSession: NSURLSession.sharedSession(),
            imageDecodeScheduler: backgroundScheduler,
            callbackScheduler: MainScheduler.sharedInstance
        ))
        
        let resultsTableView = self.searchDisplayController!.searchResultsTableView
        let searchBar = self.searchDisplayController!.searchBar
        
        resultsTableView.registerNib(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        
        resultsTableView.rowHeight = 194
        
        let viewModel = SearchViewModel(
            $: (
                API: API,
                imageService: imageService,
                mainScheduler: mainScheduler,
                backgroundWorkScheduler: backgroundScheduler,
                wireframe: DefaultWireframe()
            ),
            searchText: searchBar.rx_searchText(),
            selectedResult: resultsTableView.rx_elementTap()
        )
        
        // map table view rows
        // {
        viewModel.rows >- map { rows in
            replaceErrorWith(rows, [])
        } >- resultsTableView.rx_subscribeRowsToCellWithIdentifier("WikipediaSearchCell") { (_, _, viewModel, cell: WikipediaSearchCell) in
            
            cell.viewModel = viewModel
        } >- disposeBag.addDisposable
        // }

        // dismiss keyboard on scroll
        // {
        resultsTableView.rx_contentOffset() >- subscribeNext { _ in
            if searchBar.isFirstResponder() {
                _ = searchBar.resignFirstResponder()
            }
        } >- disposeBag.addDisposable
        
        disposeBag.addDisposable(viewModel)
        
        self.viewModel = viewModel
        // }
    }
    
}
