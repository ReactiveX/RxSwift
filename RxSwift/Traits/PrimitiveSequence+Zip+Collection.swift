//
//  PrimitiveSequence+Zip+Collection.swift
//  RxSwift-iOS
//
//  Created by yuzushioh on 2018/01/23.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

// MARK: zip + collection

extension PrimitiveSequenceType where TraitType == SingleTrait {
    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.
     
     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    public static func zip<C: Collection, R>(_ collection: C, _ resultSelector: @escaping ([ElementType]) throws -> R) -> PrimitiveSequence<TraitType, R> where C.Iterator.Element == PrimitiveSequence<TraitType, ElementType> {
        let raw = Observable.zip(collection.map { $0.asObservable() }, resultSelector)
        return PrimitiveSequence<TraitType, R>(raw: raw)
    }
    
    /**
     Merges the specified observable sequences into one observable sequence all of the observable sequences have produced an element at a corresponding index.
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func zip<C: Collection>(_ collection: C) -> PrimitiveSequence<TraitType, [ElementType]> where C.Iterator.Element == PrimitiveSequence<TraitType, ElementType> {
        let raw = Observable.zip(collection.map { $0.asObservable() })
        return PrimitiveSequence(raw: raw)
    }
}
