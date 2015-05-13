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
    
    init(searchResult: WikipediaSearchResult) {
        self.searchResult = searchResult
        
        self.title = never()
        self.imageURLs = never()
        
        let URLs = configureImageURLs()
        
        self.imageURLs = URLs >- catch([])
        self.title = configureTitle(URLs) >- catch("Error during fetching")
    }
    
    // private methods
    
    func configureTitle(imageURLs: Observable<[NSURL]>) -> Observable<String> {
        var searchResult = self.searchResult
       
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
        return Dependencies.sharedDependencies.API.articleContent(searchResult)
            >- observeSingleOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            >- map { page in
                parseImageURLsfromHTMLSuitableForDisplay(page.text)
            }
            >- observeSingleOn(Dependencies.sharedDependencies.mainScheduler)
            >- variable
    }
}