//
//  KVOObserver.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

protocol KVOObservableProtocol {
    var target: AnyObject { get }
    var keyPath: String { get }
    var retainTarget: Bool { get }
    var options: NSKeyValueObservingOptions { get }
}

class KVOObserver : _RXKVOObserver
                  , Disposable {
    typealias Callback = (Any?) -> Void

    var retainSelf: KVOObserver? = nil

    init(parent: KVOObservableProtocol, callback: @escaping Callback) {
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
