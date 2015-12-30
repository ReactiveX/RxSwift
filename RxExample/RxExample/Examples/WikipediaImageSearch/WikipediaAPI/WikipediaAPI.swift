//
//  WikipediaAPI.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

func apiError(error: String) -> NSError {
    return NSError(domain: "WikipediaAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
}

public let WikipediaParseError = apiError("Error during parsing")

protocol WikipediaAPI {
    func getSearchResults(query: String) -> Observable<[WikipediaSearchResult]>
    func articleContent(searchResult: WikipediaSearchResult) -> Observable<WikipediaPage>
}

class DefaultWikipediaAPI: WikipediaAPI {
    
    static let sharedAPI = DefaultWikipediaAPI() // Singleton
    
    let $: Dependencies = Dependencies.sharedDependencies

    let loadingWikipediaData = ActivityIndicator()

    private init() {}

    private func rx_JSON(URL: NSURL) -> Observable<AnyObject> {
        return $.URLSession
            .rx_JSON(URL)
            .trackActivity(loadingWikipediaData)
    }

    // Example wikipedia response http://en.wikipedia.org/w/api.php?action=opensearch&search=Rx
    func getSearchResults(query: String) -> Observable<[WikipediaSearchResult]> {
        let escapedQuery = query.URLEscaped
        let urlContent = "http://en.wikipedia.org/w/api.php?action=opensearch&search=\(escapedQuery)"
        let url = NSURL(string: urlContent)!
            
        return rx_JSON(url)
            .observeOn($.backgroundWorkScheduler)
            .map { json in
                guard let json = json as? [AnyObject] else {
                    throw exampleError("Parsing error")
                }
                
                return try WikipediaSearchResult.parseJSON(json)
            }
            .observeOn($.mainScheduler)
    }
    
    // http://en.wikipedia.org/w/api.php?action=parse&page=rx&format=json
    func articleContent(searchResult: WikipediaSearchResult) -> Observable<WikipediaPage> {
        let escapedPage = searchResult.title.URLEscaped
        guard let url = NSURL(string: "http://en.wikipedia.org/w/api.php?action=parse&page=\(escapedPage)&format=json") else {
            return Observable.error(apiError("Can't create url"))
        }
        
        return rx_JSON(url)
            .map { jsonResult in
                guard let json = jsonResult as? NSDictionary else {
                    throw exampleError("Parsing error")
                }
                
                return try WikipediaPage.parseJSON(json)
            }
            .observeOn($.mainScheduler)
    }
}