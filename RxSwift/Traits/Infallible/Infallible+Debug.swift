//
//  Infallible+Debug.swift
//  RxSwift
//
//  Created by Marcelo Fabri on 11/05/2023.
//  Copyright © 2023 RxSwift. All rights reserved.
//

extension InfallibleType {
    /**
     Prints received events for all observers on standard output.

     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

     - parameter identifier: Identifier that is printed together with event description to standard output.
     - parameter trimOutput: Should output be trimmed to max 40 characters.
     - returns: An Infallible sequence whose events are printed to standard output.
     */
    public func debug(_ identifier: String? = nil, trimOutput: Bool = false, file: String = #file, line: UInt = #line, function: String = #function)
        -> Infallible<Element> {
        Infallible(
            asObservable()
            .debug(identifier, trimOutput: trimOutput, file: file, line: line, function: function)
        )
    }
}
