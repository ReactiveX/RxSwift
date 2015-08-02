//
//  WikipediaPage.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

struct WikipediaPage {
    let title: String
    let text: String
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
    }
    
    // tedious parsing part
    static func parseJSON(json: NSDictionary) -> RxResult<WikipediaPage> {
        let title = json.valueForKey("parse")?.valueForKey("title") as? String
        let text = json.valueForKey("parse")?.valueForKey("text")?.valueForKey("*") as? String
        
        if title == nil || text == nil {
            return failure(apiError("Error parsing page content"))
        }
        
        return success(WikipediaPage(title: title!, text: text!))
    }
}