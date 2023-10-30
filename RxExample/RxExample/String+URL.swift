//
//  String+URL.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


extension String {
    var URLEscaped: String {
       self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
