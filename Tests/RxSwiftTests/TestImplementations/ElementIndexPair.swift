//
//  ElementIndexPair.swift
//  Tests
//
//  Created by Krunoslav Zaher on 6/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

struct ElementIndexPair<Element: Equatable, I: Equatable> : Equatable {
    let element: Element
    let index: I
    
    init(_ element: Element, _ index: I) {
        self.element = element
        self.index = index
    }
}

func == <Element, I>(lhs: ElementIndexPair<Element, I>, rhs: ElementIndexPair<Element, I>) -> Bool {
    return lhs.element == rhs.element && lhs.index == rhs.index
}
