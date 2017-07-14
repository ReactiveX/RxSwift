//
//  HtmlParsing.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import class Foundation.NSString
import class Foundation.NSRegularExpression
import func Foundation.NSMakeRange
import struct Foundation.URL

func parseImageURLsfromHTML(_ html: NSString) throws -> [URL]  {
    let regularExpression = try NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]+)\"[^>]*>", options: [])
    
    let matches = regularExpression.matches(in: html as String, options: [], range: NSMakeRange(0, html.length))
    
    return matches.map { match -> URL? in
        if match.numberOfRanges != 2 {
            return nil
        }
        
        let url = html.substring(with: match.range(at: 1))
        
        var absoluteURLString = url
        if url.hasPrefix("//") {
             absoluteURLString = "http:" + url
        }
        
        return URL(string: absoluteURLString)
    }.filter { $0 != nil }.map { $0! }
}

func parseImageURLsfromHTMLSuitableForDisplay(_ html: NSString) throws -> [URL] {
    return try parseImageURLsfromHTML(html).filter {
        return $0.absoluteString.range(of: ".svg.") == nil
    }
}
