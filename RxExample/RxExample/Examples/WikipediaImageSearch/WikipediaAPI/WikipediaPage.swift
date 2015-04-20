//
//  WikipediaPage.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

struct WikipediaPage {
    let title: String
    let text: String
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
    }
    
    // tedious parsing part
    static func parseJSON(json: NSDictionary) -> Result<WikipediaPage> {
        let title = json.valueForKey("parse")?.valueForKey("title") as? String
        let text = json.valueForKey("parse")?.valueForKey("text")?.valueForKey("*") as? String
        
        if title == nil || text == nil {
            return .Error(apiError("Error parsing page content"))
        }
        
        return success(WikipediaPage(title: title!, text: text!))
    }
}