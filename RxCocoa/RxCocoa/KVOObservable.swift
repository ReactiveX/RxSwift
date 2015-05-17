//
//  KVOObservable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class KVOObserver<Element> : NSObject, Disposable {
    typealias Callback = (Element) -> Void
    
    let object: NSObject
    let callback: Callback!
    let path: String
    
    var retainSelf: KVOObserver<Element>? = nil
    
    init(object: NSObject, path: String, callback: Callback) {
        self.object = object
        self.path = path
        self.callback = nil
        
        super.init()
        
        self.retainSelf = self
        
        self.object.addObserver(self, forKeyPath: self.path, options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        let newValue = change[NSKeyValueChangeNewKey] as! Element
        
        self.callback(newValue)
    }
    
    func dispose() {
        self.object.removeObserver(self, forKeyPath: self.path)
        
        self.retainSelf = nil
    }
    
    deinit {
    }
}

public class KVOObservable<Element> : Observable<Element> {
    let object: NSObject
    let path: String
    
    public init(object: NSObject, path: String) {
        self.object = object
        self.path = path
    }
    
    public override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        let observer = KVOObserver(object: object, path: path) { [unowned self] value in
            observer.on(.Next(Box(value)))
        }
        
        return AnonymousDisposable { () in
            observer.dispose()
        }
    }
}