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
    typealias Dependencies = (
        API: WikipediaAPI,
        imageService: ImageService,
        backgroundWorkScheduler: ImmediateScheduler,
        mainScheduler: DispatchQueueScheduler,
        wireframe: Wireframe
    )
    
    // outputs
    let rows: Observable<[SearchResultViewModel]>
    
    var $: Dependencies
    
    let disposeBag = DisposeBag()

    // public methods
    
    init($: Dependencies,
        searchText: Observable<String>,
        selectedResult: Observable<SearchResultViewModel>) {
     
        self.$ = $
            
        let wireframe = $.wireframe
        let API = $.API
            
        self.rows = searchText >- throttle(300, $.mainScheduler) >- distinctUntilChanged >- map { query in
            $.API.getSearchResults(query)
                >- prefixWith([]) // clears results on new search term
                >- catch([])
        } >- switchLatest >- map { results in
            results.map {
                SearchResultViewModel(
                    $: $,
                    searchResult: $0
                )
            }
        }
            
        selectedResult >- subscribeNext { searchResult in
            $.wireframe.openURL(searchResult.searchResult.URL)
        } >- disposeBag.addDisposable
    }

    func dispose() {
        disposeBag.dispose()
    }
}