//
//  String+Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension String {
    /**
     This is needed because on Linux Swift doesn't have `rangeOfString(..., options: .BackwardsSearch)`
    */
    func lastIndexOf(character: Character) -> Index? {
        
        var idx = endIndex
        while idx > startIndex {
            idx = index(before: idx)
            if self[idx] == character {
                return idx
            }
        }

        return nil
    }
}
