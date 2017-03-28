//
//  PremitiveSequence+Debug.swift
//  Rx
//
//  Created by muukii on 3/13/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

// MARK: debug

extension PrimitiveSequence {

  /**
   Prints received events for all observers on standard output.

   - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

   - parameter identifier: Identifier that is printed together with event description to standard output.
   - parameter trimOutput: Should output be trimmed to max 40 characters.
   - returns: An observable sequence whose events are printed to standard output.
   */
  public func debug(_ identifier: String? = nil, trimOutput: Bool = false, file: String = #file, line: UInt = #line, function: String = #function)
    -> Observable<E> {
      return Debug(source: self.source, identifier: identifier, trimOutput: trimOutput, file: file, line: line, function: function)
  }
}
