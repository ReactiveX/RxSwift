//
//  SearchViewModel.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel: Disposable {
    
    // outputs
    let rows: Observable<[SearchResultViewModel]>
    
    let subscriptions = CompositeDisposable()

    // public methods
    
    init(searchText: Observable<String>,
        selectedResult: Observable<SearchResultViewModel>) {
        
        let $: Dependencies = Dependencies.sharedDependencies
        let wireframe = Dependencies.sharedDependencies.wireframe
        let API = DefaultWikipediaAPI.sharedAPI
        
        self.rows = searchText
            >- throttle(0.3, $.mainScheduler)
            >- distinctUntilChanged
            >- map { query in
                API.getSearchResults(query)
                    >- startWith([]) // clears results on new search term
                    >- onError ([])
            }
            >- switchLatest
            >- map { results in
                results.map {
                    SearchResultViewModel(
                        searchResult: $0
                    )
                }
        }
        
        selectedResult
            >- subscribeNext { searchResult in
                wireframe.openURL(searchResult.searchResult.URL)
            }
            >- subscriptions.addDisposable
    }

    func dispose() {
        subscriptions.dispose()
    }
}