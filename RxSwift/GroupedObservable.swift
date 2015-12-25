//
//  GroupedObservable.swift
//  Rx
//
//  Created by Tomi Koskinen on 01/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents an observable sequence of elements that have a common key.
*/
public class GroupedObservable<Key, Element> : Observable<Element> {
    /**
     The type of the key shared by all elements in the group.
     */
    public typealias K = Key
    
    /**
     Gets the common key.
     */
    public let key: Key
    
    public init(key: Key) {
        self.key = key
        super.init()
    }
        
    public override func subscribe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        abstractMethod()
    }

    public override func asObservable() -> GroupedObservable<Key, Element> {
        return self
    }
}