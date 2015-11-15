//
//  KVOObservable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
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
    
    func subscribe<O : ObserverType where O.E == Element?>(observer: O) -> Disposable {
        let observer = KVOObserver(parent: self) { (value) in
            if value as? NSNull != nil {
                observer.on(.Next(nil))
                return
            }
            observer.on(.Next(value as? Element))
        }
        
        return AnonymousDisposable {
            observer.dispose()
        }
    }
    
}

#if !DISABLE_SWIZZLING

func observeWeaklyKeyPathFor(target: NSObject, keyPath: String, options: NSKeyValueObservingOptions) -> Observable<AnyObject?> {
    let components = keyPath.componentsSeparatedByString(".").filter { $0 != "self" }
    
    let observable = observeWeaklyKeyPathFor(target, keyPathSections: components, options: options)
        .distinctUntilChanged { $0 === $1 }
        .finishWithNilWhenDealloc(target)
 
    if !options.intersect(.Initial).isEmpty {
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
func isWeakProperty(properyRuntimeInfo: String) -> Bool {
    return properyRuntimeInfo.rangeOfString(",W,") != nil
}

extension ObservableType where E == AnyObject? {
    func finishWithNilWhenDealloc(target: NSObject)
        -> Observable<AnyObject?> {
        let deallocating = target.rx_deallocating
            
        return deallocating
            .map { _ in
                return just(nil)
            }
            .startWith(self.asObservable())
            .switchLatest()
    }
}

func observeWeaklyKeyPathFor(
        target: NSObject,
        keyPathSections: [String],
        options: NSKeyValueObservingOptions
    ) -> Observable<AnyObject?> {
    
    weak var weakTarget: AnyObject? = target
        
    let propertyName = keyPathSections[0]
    let remainingPaths = Array(keyPathSections[1..<keyPathSections.count])
    
    let property = class_getProperty(object_getClass(target), propertyName);
    if property == nil {
        return failWith(RxCocoaError.InvalidPropertyName(object: target, propertyName: propertyName))
    }
    let propertyAttributes = property_getAttributes(property);
    
    // should dealloc hook be in place if week property, or just create strong reference because it doesn't matter
    let isWeak = isWeakProperty(String.fromCString(propertyAttributes) ?? "")
    let propertyObservable = KVOObservable(object: target, keyPath: propertyName, options: options.union(.Initial), retainTarget: false) as KVOObservable<AnyObject>
    
    // KVO recursion for value changes
    return propertyObservable
        .flatMapLatest { (nextTarget: AnyObject?) -> Observable<AnyObject?> in
            if nextTarget == nil {
               return just(nil)
            }
            let nextObject = nextTarget! as? NSObject

            let strongTarget: AnyObject? = weakTarget
            
            if nextObject == nil {
                return failWith(RxCocoaError.InvalidObjectOnKeyPath(object: nextTarget!, sourceObject: strongTarget ?? NSNull(), propertyName: propertyName))
            }

            // if target is alive, then send change
            // if it's deallocated, don't send anything
            if strongTarget == nil {
                return empty()
            }
            
            let nextElementsObservable = keyPathSections.count == 1
                ? just(nextTarget)
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

