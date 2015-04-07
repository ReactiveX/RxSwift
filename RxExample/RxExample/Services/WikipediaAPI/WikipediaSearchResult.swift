//
//  WikipediaSearchResult.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Rx

struct WikipediaSearchResult: Printable {
    let title: String
    let description: String
    let URL: NSURL
    
    init(title: String, description: String, URL: NSURL) {
        self.title = title
        self.description = description
        self.URL = URL
    }
    
    // tedious parsing part
    static func parseJSON(json: [AnyObject]) -> Result<[WikipediaSearchResult]> {
        let rootArrayTyped = json.map { $0 as? [AnyObject] }
            .filter { $0 != nil }
            .map { $0! }
        
        if rootArrayTyped.count != 3 {
            return .Error(WikipediaParseError)
        }
        
        let titleAndDescription = Array(Zip2(rootArrayTyped[0], rootArrayTyped[1]))
        let titleDescriptionAndUrl: [((AnyObject, AnyObject), AnyObject)] = Array(Zip2(titleAndDescription, rootArrayTyped[2]))
        
        let searchResults: [Result<WikipediaSearchResult>] = titleDescriptionAndUrl.map ( { result -> Result<WikipediaSearchResult> in
            let ((title: AnyObject, description: AnyObject), url: AnyObject) = result
            
            let titleString = title as? String,
            descriptionString = description as? String,
            urlString = url as? String
            
            if titleString == nil || descriptionString == nil || urlString == nil {
                return .Error(WikipediaParseError)
            }
            
            let URL = NSURL(string: urlString!)
            if URL == nil {
                return .Error(WikipediaParseError)
            }
            
            return success(WikipediaSearchResult(title: titleString!, description: descriptionString!, URL: URL!))
        })
        
        let values = (searchResults.filter { $0.value != nil }).map { *$0 }
        
        return success(values)
    }
}
