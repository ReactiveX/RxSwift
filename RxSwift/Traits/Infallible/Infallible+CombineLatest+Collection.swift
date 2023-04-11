//
//  Infallible+CombineLatest+Collection.swift
//  RxSwift
//
//  Created by Hal Lee on 4/11/23.
//  Copyright © 2023 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension InfallibleType {
    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.

     - seealso: [combinelatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)

     - parameter resultSelector: Function to invoke whenever any of the sources produces an element.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    public static func combineLatest<Collection: Swift.Collection>(_ collection: Collection, resultSelector: @escaping ([Collection.Element.Element]) throws -> Element) -> Infallible<Element>
        where Collection.Element: InfallibleType {
        Infallible(CombineLatestCollectionType(sources: collection, resultSelector: resultSelector))
    }

    /**
     Merges the specified observable sequences into one observable sequence whenever any of the observable sequences produces an element.

     - seealso: [combinelatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)

     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<Collection: Swift.Collection>(_ collection: Collection) -> Infallible<[Element]>
        where Collection.Element: InfallibleType, Collection.Element.Element == Element {
        Infallible(CombineLatestCollectionType(sources: collection) { $0 })
    }
}
