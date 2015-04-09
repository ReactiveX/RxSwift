//
//  KVOObservable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class KVOObserver<Element> : NSObject {
    typealias Callback = (Element) -> Void
    
    let object: NSObject
    let callback: Callback!
    let path: String
    
    init(object: NSObject, path: String, callback: Callback) {
        self.object = object
        self.path = path
        self.callback = nil
        
        super.init()
        
        self.object.addObserver(self, forKeyPath: self.path, options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        let newValue = change[NSKeyValueChangeNewKey] as! Element
        
        self.callback(newValue)
    }
    
    deinit {
        self.object.removeObserver(self, forKeyPath: self.path)
    }
}

/**
*  This class should be used from main thread only
*/
public class KVOObservable<Element> : Observable<Element> {
    var observer: KVOObserver<Element>!
    
    var observers: Bag<ObserverOf<Element>>
    
    var lock = Lock()
    
    public init(object: NSObject, path: String) {
        self.observers = Bag()
        
        self.observer = nil
        
        super.init()
        
        self.observer = KVOObserver(object: object, path: path) { [unowned self] value in
            let observers = self.observers
            let invokeResult = doAll(observers.all.map { observer in
                observer.on(.Next(Box(value)))
            })
            
            handleObserverResult(invokeResult)
        }
    }
    
    public override func subscribe(observer: ObserverOf<Element>) -> Result<Disposable> {
        return lock.calculateLocked {
            let key = self.observers.put(observer)
            
            return success(AnonymousDisposable { () in
                self.lock.performLocked {
                    _ = self.observers.removeKey(key)
                }
            })
        }
    }
}