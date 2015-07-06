//
//  SearchResultViewModel.swift
//  Example
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SearchResultViewModel {
    let searchResult: WikipediaSearchResult
    
    var title: Observable<String>
    var imageURLs: Observable<[NSURL]>
    
    let API = DefaultWikipediaAPI.sharedAPI
    let $: Dependencies = Dependencies.sharedDependencies
    
    init(searchResult: WikipediaSearchResult) {
        self.searchResult = searchResult
        
        self.title = never()
        self.imageURLs = never()
        
        let URLs = configureImageURLs()
        
        self.imageURLs = URLs >- onError ([])
        self.title = configureTitle(URLs) >- onError("Error during fetching")
    }
    
    // private methods
    
    func configureTitle(imageURLs: Observable<[NSURL]>) -> Observable<String> {
        let searchResult = self.searchResult
       
        let loadingValue: [NSURL]? = nil
        
        return imageURLs
            >- map { makeOptional($0) }
            >- startWith(loadingValue)
            >- map { URLs in
                if let URLs = URLs {
                    return "\(searchResult.title) (\(URLs.count)) pictures)"
                }
                else {
                    return "\(searchResult.title) loading ..."
                }
            }
    }
    
    func configureImageURLs() -> Observable<[NSURL]> {
        let searchResult = self.searchResult
        return API.articleContent(searchResult)
            >- observeSingleOn($.backgroundWorkScheduler)
            >- map { page in
                do {
                    return try parseImageURLsfromHTMLSuitableForDisplay(page.text)
                } catch {
                    return []
                }
            }
            >- observeSingleOn($.mainScheduler)
            >- variable
    }
}