//
//  WikipediaPage.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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
    static func parseJSON(_ json: NSDictionary) throws -> WikipediaPage {
        guard let title = json.value(forKey: "parse")?.value(forKey: "title") as? String,
              let text = json.value(forKey: "parse")?.value(forKey: "text")?.value(forKey: "*") as? String else {
            throw apiError("Error parsing page content")
        }
        
        return WikipediaPage(title: title, text: text)
    }
}
