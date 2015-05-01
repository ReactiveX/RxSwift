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
            dispatch(.Next(Box(value)), observers)
        }
    }
    
    public override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        return lock.calculateLocked {
            let key = self.observers.put(ObserverOf(observer))
            
            return AnonymousDisposable { () in
                self.lock.performLocked {
                    if self.observers.removeKey(key) == nil {
                        removingObserverFailed()
                    }
                }
            }
        }
    }
}