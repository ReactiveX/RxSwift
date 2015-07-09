//
//  KVOObservable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

var context: UInt8 = 0

protocol KVOObservableProtocol {
    var object: NSObject { get }
    var path: String { get }
    var options: NSKeyValueObservingOptions { get }
}

class KVOObserver : NSObject
                  , Disposable {
    typealias Callback = (AnyObject?) -> Void
    
    let parent: KVOObservableProtocol
    let callback: Callback
    
    var retainSelf: KVOObserver?
    
    init(parent: KVOObservableProtocol, callback: Callback) {
        self.parent = parent
        self.callback = callback
        
    #if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
    #endif
        
        super.init()
        
        retainSelf = self
        
        self.parent.object.addObserver(self, forKeyPath: self.parent.path, options: self.parent.options, context: &context)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let newValue: AnyObject? = change?[NSKeyValueChangeNewKey]
        
        if let newValue: AnyObject = newValue {
            self.callback(newValue)
        }
    }
    
    func dispose() {
        self.parent.object.removeObserver(self, forKeyPath: self.parent.path)
        self.retainSelf = nil
    }
    
    deinit {
    #if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
    #endif
    }
}

class KVOObservable<Element> : Observable<Element?>, KVOObservableProtocol {
    var object: NSObject
    var path: String
    var options: NSKeyValueObservingOptions
    
    convenience init(object: NSObject, path: String) {
        self.init(object: object, path: path, options: NSKeyValueObservingOptions([.Initial, .New]))
    }
    
    init(object: NSObject, path: String, options: NSKeyValueObservingOptions) {
        self.object = object
        self.path = path
        self.options = options
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

