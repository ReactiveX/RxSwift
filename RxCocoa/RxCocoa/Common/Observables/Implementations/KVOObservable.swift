//
//  KVOObservable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

protocol KVOObservableProtocol {
    var target: NSObject { get }
    var keyPath: String { get }
    var retainTarget: Bool { get }
    var options: NSKeyValueObservingOptions { get }
}

class KVOObserver : _RXKVOObserver
                  , Disposable {
    typealias Callback = (AnyObject?) -> Void

    var retainSelf: KVOObserver? = nil

    init(parent: KVOObservableProtocol, callback: Callback) {
    #if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
    #endif
        
        super.init(target: parent.target, retainTarget: parent.retainTarget, keyPath: parent.keyPath, options: parent.options, callback: callback)
        self.retainSelf = self
    }
    
    override func dispose() {
        super.dispose()
        self.retainSelf = nil
    }
    
    deinit {
    #if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
    #endif
    }
}

class KVOObservable<Element> : Observable<Element?>, KVOObservableProtocol {
    unowned var target: NSObject
    var strongTarget: NSObject?
    
    var keyPath: String
    var options: NSKeyValueObservingOptions
    var retainTarget: Bool
    
    init(object: NSObject, path: String, options: NSKeyValueObservingOptions, retainTarget: Bool) {
        self.target = object
        self.keyPath = path
        self.options = options
        self.retainTarget = retainTarget
        if retainTarget {
            self.strongTarget = object
        }
    }
    
    override func subscribe<O : ObserverType where O.Element == Element?>(observer: O) -> Disposable {
        let observer = KVOObserver(parent: self) { (value) in
            sendNext(observer, value as? Element)
        }
        
        return AnonymousDisposable {
            observer.dispose()
        }
    }
}

