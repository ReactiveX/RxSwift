//
//  String+extensions.swift
//  RxExample
//
//  Created by carlos on 28/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

extension String {
    
    func uppercaseFirstCharacter() -> String {
        var result = Array(self)
        if !isEmpty { result[0] = Character(String(result.first!).uppercaseString) }
        return String(result)
    }
    
}
