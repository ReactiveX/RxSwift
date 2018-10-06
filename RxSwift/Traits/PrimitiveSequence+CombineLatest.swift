//
//  PrimitiveSequence+CombineLatest.swift
//  RxSwift-iOS
//
//  Created by Ryo Fukuda on 2018/10/07.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

extension PrimitiveSequenceType where TraitType == SingleTrait {
    /**
     Merges the specified observable sequences into one observable sequence of tuples whenever any of the observable sequences produces an element.
     
     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<E1, E2>(_ source1: PrimitiveSequence<TraitType, E1>, _ source2: PrimitiveSequence<TraitType, E2>) -> PrimitiveSequence<TraitType, (E1, E2)> {
        return PrimitiveSequence(raw: Observable.combineLatest(source1.asObservable(), source2.asObservable()))
    }
    
    /**
     Merges the specified observable sequences into one observable sequence of tuples whenever any of the observable sequences produces an element.
     
     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<E1, E2, E3>(_ source1: PrimitiveSequence<TraitType, E1>, _ source2: PrimitiveSequence<TraitType, E2>, _ source3: PrimitiveSequence<TraitType, E3>) -> PrimitiveSequence<TraitType, (E1, E2, E3)> {
        return PrimitiveSequence(raw: Observable.combineLatest(source1.asObservable(), source2.asObservable(), source3.asObservable()))
    }
    
    /**
     Merges the specified observable sequences into one observable sequence of tuples whenever any of the observable sequences produces an element.
     
     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<E1, E2, E3, E4>(_ source1: PrimitiveSequence<TraitType, E1>, _ source2: PrimitiveSequence<TraitType, E2>, _ source3: PrimitiveSequence<TraitType, E3>, _ source4: PrimitiveSequence<TraitType, E4>) -> PrimitiveSequence<TraitType, (E1, E2, E3, E4)> {
        return PrimitiveSequence(raw: Observable.combineLatest(source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable()))
    }
    
    /**
     Merges the specified observable sequences into one observable sequence of tuples whenever any of the observable sequences produces an element.
     
     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<E1, E2, E3, E4, E5>(_ source1: PrimitiveSequence<TraitType, E1>, _ source2: PrimitiveSequence<TraitType, E2>, _ source3: PrimitiveSequence<TraitType, E3>, _ source4: PrimitiveSequence<TraitType, E4>, _ source5: PrimitiveSequence<TraitType, E5>) -> PrimitiveSequence<TraitType, (E1, E2, E3, E4, E5)> {
        return PrimitiveSequence(raw: Observable.combineLatest(source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable()))
    }
    
    /**
     Merges the specified observable sequences into one observable sequence of tuples whenever any of the observable sequences produces an element.
     
     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<E1, E2, E3, E4, E5, E6>(_ source1: PrimitiveSequence<TraitType, E1>, _ source2: PrimitiveSequence<TraitType, E2>, _ source3: PrimitiveSequence<TraitType, E3>, _ source4: PrimitiveSequence<TraitType, E4>, _ source5: PrimitiveSequence<TraitType, E5>, _ source6: PrimitiveSequence<TraitType, E6>) -> PrimitiveSequence<TraitType, (E1, E2, E3, E4, E5, E6)> {
        return PrimitiveSequence(raw: Observable.combineLatest(source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable()))
    }
    
    /**
     Merges the specified observable sequences into one observable sequence of tuples whenever any of the observable sequences produces an element.
     
     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<E1, E2, E3, E4, E5, E6, E7>(_ source1: PrimitiveSequence<TraitType, E1>, _ source2: PrimitiveSequence<TraitType, E2>, _ source3: PrimitiveSequence<TraitType, E3>, _ source4: PrimitiveSequence<TraitType, E4>, _ source5: PrimitiveSequence<TraitType, E5>, _ source6: PrimitiveSequence<TraitType, E6>, _ source7: PrimitiveSequence<TraitType, E7>) -> PrimitiveSequence<TraitType, (E1, E2, E3, E4, E5, E6, E7)> {
        return PrimitiveSequence(raw: Observable.combineLatest(source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable()))
    }
    
    /**
     Merges the specified observable sequences into one observable sequence of tuples whenever any of the observable sequences produces an element.
     
     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<E1, E2, E3, E4, E5, E6, E7, E8>(_ source1: PrimitiveSequence<TraitType, E1>, _ source2: PrimitiveSequence<TraitType, E2>, _ source3: PrimitiveSequence<TraitType, E3>, _ source4: PrimitiveSequence<TraitType, E4>, _ source5: PrimitiveSequence<TraitType, E5>, _ source6: PrimitiveSequence<TraitType, E6>, _ source7: PrimitiveSequence<TraitType, E7>, _ source8: PrimitiveSequence<TraitType, E8>) -> PrimitiveSequence<TraitType, (E1, E2, E3, E4, E5, E6, E7, E8)> {
        return PrimitiveSequence(raw: Observable.combineLatest(source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable(), source8.asObservable()))
    }
}

extension PrimitiveSequenceType where TraitType == SingleTrait {
    /**
     Merges the specified observable sequences into one observable sequence of tuples whenever any of the observable sequences produces an element.
     
     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<C: Collection>(_ collection: C) -> PrimitiveSequence<TraitType, [ElementType]> where C.Iterator.Element == PrimitiveSequence<TraitType, ElementType> {
        
        if collection.isEmpty {
            return PrimitiveSequence<TraitType, [ElementType]>(raw: .just([]))
        }
        
        let raw = Observable.zip(collection.map { $0.asObservable() })
        return PrimitiveSequence(raw: raw)
    }
}
