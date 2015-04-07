//
//  SearchResultViewModel.swift
//  Example
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Rx
import RxCocoa

class SearchResultViewModel {
    let searchResult: WikipediaSearchResult
    
    var title: Observable<String>
    var imageURLs: Observable<Result<[NSURL]>>
    
    var $: SearchViewModel.Dependencies
    
    init($: SearchViewModel.Dependencies, searchResult: WikipediaSearchResult) {
        self.searchResult = searchResult
       
        self.$ = $
        
        self.title = never()
        self.imageURLs = never()
        
        self.imageURLs = configureImageURLs()
        self.title = configureTitle(self.imageURLs)
    }
    
    // private methods
    
    func configureTitle(imageURLs: Observable<Result<[NSURL]>>) -> Observable<String> {
        var searchResult = self.searchResult
       
        let loadingValue: [NSURL]? = nil
        
        return imageURLs >- map {
            makeOptional(replaceErrorWith($0, []))
        } >- prefixWith(loadingValue) >- map { URLs in
            if let URLs = URLs {
                return "\(searchResult.title) (\(URLs.count)) pictures)"
            }
            else {
                return "\(searchResult.title) loading ..."
            }
        }
    }
    
    func configureImageURLs() -> Observable<Result<[NSURL]>> {
        let searchResult = self.searchResult
        return $.API.articleContent(searchResult) >- observeSingleOn($.backgroundWorkScheduler) >- map { (maybePage) in
                maybePage >== { page in
                    let URLs = success(parseImageURLsfromHTMLSuitableForDisplay(page.text))
                    return URLs
                } >>! { e in
                    return success([])
                }
            } >- observeSingleOn($.mainScheduler) >- sharedSubscriptionWithCachedResult
    }
}