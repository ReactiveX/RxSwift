//
//  KVOObservable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

class KVOObservable<Element>
    : ObservableType
    , KVOObservableProtocol {
    typealias E = Element?

    unowned var target: AnyObject
    var strongTarget: AnyObject?
    
    var keyPath: String
    var options: NSKeyValueObservingOptions
    var retainTarget: Bool
    
    init(object: AnyObject, keyPath: String, options: NSKeyValueObservingOptions, retainTarget: Bool) {
        self.target = object
        self.keyPath = keyPath
        self.options = options
        self.retainTarget = retainTarget
        if retainTarget {
            self.strongTarget = object
        }
    }
    
    func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element? {
        let observer = KVOObserver(parent: self) { (value) in
            if value as? NSNull != nil {
                observer.on(.next(nil))
                return
            }
            observer.on(.next(value as? Element))
        }
        
        return Disposables.create(with: observer.dispose)
    }
    
}

#if !DISABLE_SWIZZLING

func observeWeaklyKeyPathFor(_ target: NSObject, keyPath: String, options: NSKeyValueObservingOptions) -> Observable<AnyObject?> {
    let components = keyPath.components(separatedBy: ".").filter { $0 != "self" }
    
    let observable = observeWeaklyKeyPathFor(target, keyPathSections: components, options: options)
        .finishWithNilWhenDealloc(target)
 
    if !options.intersection(.initial).isEmpty {
        return observable
    }
    else {
        return observable
            .skip(1)
    }
}

// This should work correctly
// Identifiers can't contain `,`, so the only place where `,` can appear
// is as a delimiter.
// This means there is `W` as element in an array of property attributes.
func isWeakProperty(_ properyRuntimeInfo: String) -> Bool {
    return properyRuntimeInfo.range(of: ",W,") != nil
}

extension ObservableType where E == AnyObject? {
    func finishWithNilWhenDealloc(_ target: NSObject)
        -> Observable<AnyObject?> {
        let deallocating = target.rx.deallocating
            
        return deallocating
            .map { _ in
                return Observable.just(nil)
            }
            .startWith(self.asObservable())
            .switchLatest()
    }
}

func observeWeaklyKeyPathFor(
        _ target: NSObject,
        keyPathSections: [String],
        options: NSKeyValueObservingOptions
    ) -> Observable<AnyObject?> {
    
    weak var weakTarget: AnyObject? = target
        
    let propertyName = keyPathSections[0]
    let remainingPaths = Array(keyPathSections[1..<keyPathSections.count])
    
    let property = class_getProperty(object_getClass(target), propertyName)
    if property == nil {
        return Observable.error(RxCocoaError.invalidPropertyName(object: target, propertyName: propertyName))
    }
    let propertyAttributes = property_getAttributes(property)
    
    // should dealloc hook be in place if week property, or just create strong reference because it doesn't matter
    let isWeak = isWeakProperty(propertyAttributes.map(String.init) ?? "")
    let propertyObservable = KVOObservable(object: target, keyPath: propertyName, options: options.union(.initial), retainTarget: false) as KVOObservable<AnyObject>
    
    // KVO recursion for value changes
    return propertyObservable
        .flatMapLatest { (nextTarget: AnyObject?) -> Observable<AnyObject?> in
            if nextTarget == nil {
               return Observable.just(nil)
            }
            let nextObject = nextTarget! as? NSObject

            let strongTarget: AnyObject? = weakTarget
            
            if nextObject == nil {
                return Observable.error(RxCocoaError.invalidObjectOnKeyPath(object: nextTarget!, sourceObject: strongTarget ?? NSNull(), propertyName: propertyName))
            }

            // if target is alive, then send change
            // if it's deallocated, don't send anything
            if strongTarget == nil {
                return Observable.empty()
            }
            
            let nextElementsObservable = keyPathSections.count == 1
                ? Observable.just(nextTarget)
                : observeWeaklyKeyPathFor(nextObject!, keyPathSections: remainingPaths, options: options)
           
            if isWeak {
                return nextElementsObservable
                    .finishWithNilWhenDealloc(nextObject!)
            }
            else {
                return nextElementsObservable
            }
        }
}
#endif

