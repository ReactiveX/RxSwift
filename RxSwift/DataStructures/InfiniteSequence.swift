//
//  InfiniteSequence.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/13/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class InifiniteSequence<E> : SequenceType {
    typealias Element = E
    typealias Generator = AnyGenerator<E>
    
    let repeatedValue: E
    
    init(repeatedValue: E) {
        self.repeatedValue = repeatedValue
    }
    
    func generate() -> Generator {
        let repeatedValue = self.repeatedValue
        return anyGenerator {
            return repeatedValue
        }
    }
}