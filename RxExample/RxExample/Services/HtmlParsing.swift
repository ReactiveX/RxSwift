//
//  HtmlParsing.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

func parseImageURLsfromHTML(html: NSString) throws -> [NSURL]  {
    let regularExpression = try NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]+)\"[^>]*>", options: [])
    
    let matches = regularExpression.matchesInString(html as String, options: [], range: NSMakeRange(0, html.length))
    
    return matches.map { match -> NSURL? in
        if match.numberOfRanges != 2 {
            return nil
        }
        
        let url = html.substringWithRange(match.rangeAtIndex(1))
        
        var absoluteURLString = url
        if url.hasPrefix("//") {
             absoluteURLString = "http:" + url
        }
        
        return NSURL(string: absoluteURLString)
    }.filter { $0 != nil }.map { $0! }
}

func parseImageURLsfromHTMLSuitableForDisplay(html: NSString) throws -> [NSURL] {
    return try parseImageURLsfromHTML(html).filter {
        return $0.absoluteString.rangeOfString(".svg.") == nil
    }
}