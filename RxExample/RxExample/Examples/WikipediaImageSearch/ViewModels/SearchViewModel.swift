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
    
    let disposeBag = DisposeBag()

    // public methods
    
    init(searchText: Observable<String>,
        selectedResult: Observable<SearchResultViewModel>) {
            
        self.rows = searchText >- throttle(300, Dependencies.sharedDependencies.mainScheduler) >- distinctUntilChanged >- map { query in
            Dependencies.sharedDependencies.API.getSearchResults(query)
                >- startWith([]) // clears results on new search term
                >- catch([])
        } >- switchLatest >- map { results in
            results.map {
                SearchResultViewModel(searchResult: $0)
            }
        }
            
        selectedResult >- subscribeNext { searchResult in
            Dependencies.sharedDependencies.wireframe.openURL(searchResult.searchResult.URL)
        } >- disposeBag.addDisposable
    }

    func dispose() {
        disposeBag.dispose()
    }
}