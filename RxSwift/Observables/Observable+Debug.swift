//
//  Observable+Debug.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// debug

extension ObservableType {
    
    /**
    Prints received events for all observers on standard output.
    
    - parameter identifier: Identifier that is printed together with event description to standard output.
    - returns: An observable sequence whose events are printed to standard output.
    */
    public func debug(identifier: String = "\(__FILE__):\(__LINE__)")
        -> Observable<E> {
        return Debug(source: self.asObservable(), identifier: identifier)
    }
}