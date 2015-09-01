//
//  DelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

var delegateAssociatedTag: UInt8 = 0
var dataSourceAssociatedTag: UInt8 = 0

// This should be only used from `MainScheduler`
// 
// Also, please take a look at `DelegateProxyType` protocol implementation
public class DelegateProxy : _RXDelegateProxy {
    
    private var subjectsForSelector = [Selector: PublishSubject<[AnyObject]>]()

    unowned let parentObject: AnyObject
    
    public required init(parentObject: AnyObject) {
        self.parentObject = parentObject
        
        MainScheduler.ensureExecutingOnScheduler()
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        super.init()
    }
    
    public func observe(selector: Selector) -> Observable<[AnyObject]> {
        if hasWiredImplementationForSelector(selector) {
            print("Delegate proxy is already implementing `\(selector)`, a more performant way of registering might exist.")
        }

        if !self.respondsToSelector(selector) {
            rxFatalError("This class doesn't respond to selector \(selector)")
        }
        
        let subject = subjectsForSelector[selector]
        
        if let subject = subject {
            return subject
        }
        else {
            let subject = PublishSubject<[AnyObject]>()
            subjectsForSelector[selector] = subject
            return subject
        }
    }
    
    // proxy
    
    public override func interceptedSelector(selector: Selector, withArguments arguments: [AnyObject]!) {
        subjectsForSelector[selector]?.on(.Next(arguments))
    }
    
    class func _pointer(p: UnsafePointer<Void>) -> UnsafePointer<Void> {
        return p
    }
    
    public class func delegateAssociatedObjectTag() -> UnsafePointer<Void> {
        return _pointer(&delegateAssociatedTag)
    }
    
    public class func createProxyForObject(object: AnyObject) -> AnyObject {
        return self.init(parentObject: object)
    }
    
    public class func assignedProxyFor(object: AnyObject) -> AnyObject? {
        let maybeDelegate: AnyObject? = objc_getAssociatedObject(object, self.delegateAssociatedObjectTag())
        return castOptionalOrFatalError(maybeDelegate)
    }
    
    public class func assignProxy(proxy: AnyObject, toObject object: AnyObject) {
        precondition(proxy.isKindOfClass(self.classForCoder()))
       
        objc_setAssociatedObject(object, self.delegateAssociatedObjectTag(), proxy, .OBJC_ASSOCIATION_RETAIN)
    }
    
    public func setForwardToDelegate(delegate: AnyObject?, retainDelegate: Bool) {
        self._setForwardToDelegate(delegate, retainDelegate: retainDelegate)
    }
    
    public func forwardToDelegate() -> AnyObject? {
        return self._forwardToDelegate
    }
    
    deinit {
        for v in subjectsForSelector.values {
            v.on(.Completed)
        }
#if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
#endif
    }
}