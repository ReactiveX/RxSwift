//
//  ViewController.swift
//  Example
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import Rx
import RxCocoa

public class WikipediaSearchViewController: UIViewController {
    
    private let disposeBag: DisposeBag = DisposeBag()
    private var viewModel: SearchViewModel? = nil
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
#if DEBUG
        if resourceCount != 1 {
            println("Number of resources = \(resourceCount)")
            assert(resourceCount == 1)
        }
#endif
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
            searchText: searchBar.rx_observableSearchText(),
            selectedResult: resultsTableView.rx_observableElementTap()
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
        resultsTableView.rx_observableContentOffset() >- subscribeNext { _ in
            if searchBar.isFirstResponder() {
                _ = searchBar.resignFirstResponder()
            }
        } >- disposeBag.addDisposable
        
        disposeBag.addDisposable(viewModel)
        
        self.viewModel = viewModel
        // }
    }
    
    deinit {
#if DEBUG
        println("View controller disposed with \(resourceCount) resournces")
#endif
    }
}
