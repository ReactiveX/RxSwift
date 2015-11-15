//
//  SearchViewModel.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class SearchViewModel {
    
    // outputs
    let rows: Driver<[SearchResultViewModel]>
    
    let subscriptions = DisposeBag()

    // public methods
    
    init(searchText: Driver<String>,
        selectedResult: Driver<SearchResultViewModel>) {
        
        let $: Dependencies = Dependencies.sharedDependencies
        let wireframe = Dependencies.sharedDependencies.wireframe
        let API = DefaultWikipediaAPI.sharedAPI
        
        self.rows = searchText
            .throttle(0.3, $.mainScheduler)
            .distinctUntilChanged()
            .flatMapLatest { query in
                API.getSearchResults(query)
                    .retry(3)
                    .retryOnBecomesReachable([], reachabilityService: ReachabilityService.sharedReachabilityService)
                    .startWith([]) // clears results on new search term
                    .asDriver(onErrorJustReturn: [])
            }
            .map { results in
                results.map {
                    SearchResultViewModel(
                        searchResult: $0
                    )
                }
            }
        
        selectedResult
            .driveNext { searchResult in
                wireframe.openURL(searchResult.searchResult.URL)
            }
            .addDisposableTo(subscriptions)
    }

}