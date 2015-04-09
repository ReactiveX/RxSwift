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
    let rows: Observable<Result<[SearchResultViewModel]>>
    
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
        } >- switchLatest >- map { resultsMaybe in
            SearchViewModel.convertSearchResultModels($, resultsMaybe: resultsMaybe)
        }
            
        selectedResult >- subscribeNext { searchResult in
            $.wireframe.openURL(searchResult.searchResult.URL)
        } >- disposeBag.addDisposable
    }

    func dispose() {
        disposeBag.dispose()
    }
    
    // private methods

    class func convertSearchResultModels($: Dependencies, resultsMaybe: Result<[WikipediaSearchResult]>) -> Result<[SearchResultViewModel]> {
        return resultsMaybe >== { results in
            return success(results.map { SearchResultViewModel(
                $: $,
                searchResult: $0
                )
            })
        }
    }
    
}