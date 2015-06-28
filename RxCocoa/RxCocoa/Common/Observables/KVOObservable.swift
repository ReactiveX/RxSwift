//
//  KVOObservable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

protocol KVOObservableProtocol {
    var object: NSObject { get }
    var path: String { get }
    var options: NSKeyValueObservingOptions { get }
}

class KVOObserver : Delegate {
    typealias Callback = (AnyObject?) -> Void
    
    let parent: KVOObservableProtocol
    let callback: Callback
    
    var context: UInt8 = 0
    
    init(parent: KVOObservableProtocol, callback: Callback) {
        self.parent = parent
        self.callback = callback
        
        super.init()
        
        self.parent.object.addObserver(self, forKeyPath: self.parent.path, options: self.parent.options, context: &context)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        let newValue: AnyObject? = change[NSKeyValueChangeNewKey]
        
        if let newValue: AnyObject = newValue {
            self.callback(newValue)
        }
    }
    
    override func dispose() {
        super.dispose()
        self.parent.object.removeObserver(self, forKeyPath: self.parent.path)
    }
}

class KVOObservable<Element> : Observable<Element?>, KVOObservableProtocol {
    var object: NSObject
    var path: String
    var options: NSKeyValueObservingOptions
    
    convenience init(object: NSObject, path: String) {
        self.init(object: object, path: path, options: .Initial | .New)
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

extension NSObject {
    public func rx_observe<Element>(path: String) -> Observable<Element?> {
        return KVOObservable(object: self, path: path)
    }

    public func rx_observe<Element>(path: String, options: NSKeyValueObservingOptions) -> Observable<Element?> {
        return KVOObservable(object: self, path: path, options: options)
    }
}