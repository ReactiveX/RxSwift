//
//  WikipediaSearchResult.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

struct WikipediaSearchResult: CustomStringConvertible {
    let title: String
    let description: String
    let URL: NSURL

    init(title: String, description: String, URL: NSURL) {
        self.title = title
        self.description = description
        self.URL = URL
    }

    // tedious parsing part
    static func parseJSON(json: [AnyObject]) throws -> [WikipediaSearchResult] {
        let rootArrayTyped = json.map { $0 as? [AnyObject] }
            .filter { $0 != nil }
            .map { $0! }

        if rootArrayTyped.count != 3 {
            throw WikipediaParseError
        }

        let titleAndDescription = Array(Swift.zip(rootArrayTyped[0], rootArrayTyped[1]))
        let titleDescriptionAndUrl: [((AnyObject, AnyObject), AnyObject)] = Array(Swift.zip(titleAndDescription, rootArrayTyped[2]))
        
        let searchResults: [WikipediaSearchResult] = try titleDescriptionAndUrl.map ( { result -> WikipediaSearchResult in
            let (first, url) = result
            let (title, description) = first

            let titleString = title as? String,
            descriptionString = description as? String,
            urlString = url as? String

            if titleString == nil || descriptionString == nil || urlString == nil {
                throw WikipediaParseError
            }

            let URL = NSURL(string: urlString!)
            if URL == nil {
                throw WikipediaParseError
            }

            return WikipediaSearchResult(title: titleString!, description: descriptionString!, URL: URL!)
        })

        return searchResults
    }
}
