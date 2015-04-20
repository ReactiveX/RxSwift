//
//  WikipediaAPI.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

func apiError(error: String) -> NSError {
    return NSError(domain: "WikipediaAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
}

public let WikipediaParseError = apiError("Error during parsing")

protocol WikipediaAPI {
    func getSearchResults(query: String) -> Observable<Result<[WikipediaSearchResult]>>
    func articleContent(searchResult: WikipediaSearchResult) -> Observable<Result<WikipediaPage>>;
}

func URLEscape(pathSegment: String) -> String {
   return pathSegment.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
}

class DefaultWikipediaAPI: WikipediaAPI {
    typealias Dependencies = (
        URLSession: NSURLSession,
        callbackScheduler: ImmediateScheduler,
        backgroundScheduler: ImmediateScheduler
    )
    
    var $: Dependencies
    
    init($: Dependencies) {
        self.$ = $
    }
    
    // Example wikipedia response http://en.wikipedia.org/w/api.php?action=opensearch&search=Rx
    func getSearchResults(query: String) -> Observable<Result<[WikipediaSearchResult]>> {
        let escapedQuery = URLEscape(query)
        let urlContent = "http://en.wikipedia.org/w/api.php?action=opensearch&search=\(escapedQuery)"
        let url = NSURL(string: urlContent)!
            
        return $.URLSession.rx_JSONWithURL(url) >- observeSingleOn($.backgroundScheduler) >- mapOrDie { json in
            return castOrFail(json) >== { (json: [AnyObject]) in
                return WikipediaSearchResult.parseJSON(json)
            }
        } >- observeSingleOn($.callbackScheduler) >- catchToResult
    }
    
    // http://en.wikipedia.org/w/api.php?action=parse&page=rx&format=json
    func articleContent(searchResult: WikipediaSearchResult) -> Observable<Result<WikipediaPage>> {
        let escapedPage = URLEscape(searchResult.title)
        let url = NSURL(string: "http://en.wikipedia.org/w/api.php?action=parse&page=\(escapedPage)&format=json")
        
        if url == nil {
            return returnElement(.Error(apiError("Can't create url")))
        }
        
        return $.URLSession.rx_JSONWithURL(url!) >- mapOrDie { jsonResult in
            return castOrFail(jsonResult) >== { (json: NSDictionary) in
                return WikipediaPage.parseJSON(json)
            }
        } >- observeSingleOn($.callbackScheduler) >- catchToResult
    }
}