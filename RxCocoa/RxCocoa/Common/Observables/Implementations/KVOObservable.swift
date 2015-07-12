//
//  KVOObservable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift


class KVOObservable<Element> : Producer<Element?>
                             , KVOObservableProtocol {
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
    
    override func run<O : ObserverType where O.Element == Element?>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let observer = KVOObserver(parent: self) { (value) in
            sendNext(observer, value as? Element)
        }
        
        return AnonymousDisposable {
            observer.dispose()
        }
    }
    
}

func observeWeaklyKeyPathFor(target: NSObject, # keyPath: String, # options: NSKeyValueObservingOptions) -> Observable<AnyObject?> {
    return empty()
}

func observeWeaklyPropertyFor(target: NSObject, # named: String, # options: NSKeyValueObservingOptions) -> Observable<AnyObject?> {
    let kvoObservable = KVOObservable(object: target, keyPath: named, options: options, retainTarget: false) as KVOObservable<AnyObject>
 
    let result: Observable<AnyObject?> = target.rx_deallocating
        >- map { _ in
            return just(nil)
        }
        >- startWith(kvoObservable)
        >- switchLatest
    
    return result
}
