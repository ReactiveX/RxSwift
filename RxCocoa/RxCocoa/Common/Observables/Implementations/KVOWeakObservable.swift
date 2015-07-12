//
//  KVOWeakObservable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/*
class KVOWeakPropertyObservable<Element> : Producer<Element?>
                                         , KVOObservableProtocol {
    weak var target: NSObject?
    
    var keyPath: String
    var options: NSKeyValueObservingOptions
    var retainTarget: Bool = false
    
    init(object: NSObject, propertyName: String, options: NSKeyValueObservingOptions) {
        self.target = object
        self.keyPath = propertyName
        self.options = options
    }
    
    override func subscribeSafe<O : ObserverType where O.Element == Element?>(observer: O) -> Disposable {
        if let target = target {
            let observer = KVOObserver(parent: self) { (value) in
                sendNext(observer, value as? Element)
            }
            
            return AnonymousDisposable {
                observer.dispose()
            }
        }
        else {
            return NopDisposable.instance
        }
    }
}
*/