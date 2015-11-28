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

/**
Base class for `DelegateProxyType` protocol.

This implementation is not thread safe and can be used only from one thread (Main thread).
*/
public class DelegateProxy : _RXDelegateProxy {
    
    private var subjectsForSelector = [Selector: PublishSubject<[AnyObject]>]()

    weak var parentObject: AnyObject?
    
    /**
    Initializes new instance.
    
    - parameter parentObject: Parent object that owns `DelegateProxy` as associated object.
    */
    public required init(parentObject: AnyObject) {
        self.parentObject = parentObject
        
        MainScheduler.ensureExecutingOnScheduler()
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        super.init()
    }
    
    /**
    Returns observable sequence of invocations of delegate methods.
    
    - parameter selector: Selector used to filter observed invocations of delegate methods.
    - returns: Observable sequence of arguments passed to `selector` method.
    */
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
    
    /**
    Returns tag used to identify associated object.
    
    - returns: Associated object tag.
    */
    public class func delegateAssociatedObjectTag() -> UnsafePointer<Void> {
        return _pointer(&delegateAssociatedTag)
    }
    
    /**
    Initializes new instance of delegate proxy.
    
    - returns: Initialized instance of `self`.
    */
    public class func createProxyForObject(object: AnyObject) -> AnyObject {
        return self.init(parentObject: object)
    }
    
    /**
    Returns assigned proxy for object.
    
    - parameter object: Object that can have assigned delegate proxy.
    - returns: Assigned delegate proxy or `nil` if no delegate proxy is assigned.
    */
    public class func assignedProxyFor(object: AnyObject) -> AnyObject? {
        let maybeDelegate: AnyObject? = objc_getAssociatedObject(object, self.delegateAssociatedObjectTag())
        return castOptionalOrFatalError(maybeDelegate)
    }
    
    /**
    Assigns proxy to object.
    
    - parameter object: Object that can have assigned delegate proxy.
    - parameter proxy: Delegate proxy object to assign to `object`.
    */
    public class func assignProxy(proxy: AnyObject, toObject object: AnyObject) {
        precondition(proxy.isKindOfClass(self.classForCoder()))
       
        objc_setAssociatedObject(object, self.delegateAssociatedObjectTag(), proxy, .OBJC_ASSOCIATION_RETAIN)
    }
    
    /**
    Sets reference of normal delegate that receives all forwarded messages
    through `self`.
    
    - parameter forwardToDelegate: Reference of delegate that receives all messages through `self`.
    - parameter retainDelegate: Should `self` retain `forwardToDelegate`.
    */
    public func setForwardToDelegate(delegate: AnyObject?, retainDelegate: Bool) {
        self._setForwardToDelegate(delegate, retainDelegate: retainDelegate)
    }
   
    /**
    Returns reference of normal delegate that receives all forwarded messages
    through `self`.
    
    - returns: Value of reference if set or nil.
    */
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