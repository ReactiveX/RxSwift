//
//  HtmlParsing.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

func parseImageURLsfromHTML(html: NSString) -> [NSURL] {
    let regularExpression = NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]+)\"[^>]*>", options: NSRegularExpressionOptions.allZeros, error: nil)!
    
    let matches = regularExpression.matchesInString(html as! String, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, html.length)) as! [NSTextCheckingResult]
    
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

func parseImageURLsfromHTMLSuitableForDisplay(html: NSString) -> [NSURL] {
    return parseImageURLsfromHTML(html).filter {
        if let absoluteString = $0.absoluteString {
            return absoluteString.rangeOfString(".svg.") == nil
        }
        else {
            return false
        }
    }
}