//
//  ArrayBuilder.swift
//  RxSwift
//
//  Created by Anton Nazarov on 10/5/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

@_functionBuilder
public struct ArrayBuilder {    
    public func buildBlock<Element>(_ elements: Element...) -> [Element] {
        elements
    }
}
