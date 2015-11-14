//
//  NSObject+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

#if !DISABLE_SWIZZLING
var deallocatingSubjectTriggerContext: UInt8 = 0
var deallocatingSubjectContext: UInt8 = 0
#endif
var deallocatedSubjectTriggerContext: UInt8 = 0
var deallocatedSubjectContext: UInt8 = 0

/**
KVO is a tricky mechanism.

When observing child in a ownership hierarchy, usually retaining observing target is wanted behavior.
When observing parent in a ownership hierarchy, usually retaining target isn't wanter behavior.

KVO with weak references is especially tricky. For it to work, some kind of swizzling is required.
That can be done by
    * replacing object class dynamically (like KVO does)
    * by swizzling `dealloc` method on all instances for a class.
    * some third method ...

Both approaches can fail in certain scenarios:
    * problems arise when swizzlers return original object class (like KVO does when nobody is observing)
    * Problems can arise because replacing dealloc method isn't atomic operation (get implementation,
    set implementation).

Second approach is chosen. It can fail in case there are multiple libraries dynamically trying
to replace dealloc method. In case that isn't the case, it should be ok.
*/
extension NSObject {


    /**
     Observes values on `keyPath` starting from `self` with `options` and retains `self` if `retainSelf` is set.

     `rx_observe` is just a simple and performant wrapper around KVO mechanism.

     * it can be used to observe paths starting from `self` or from ancestors in ownership graph (`retainSelf = false`)
     * it can be used to observe paths starting from descendants in ownership graph (`retainSelf = true`)
     * the paths have to consist only of `strong` properties, otherwise you are risking crashing the system by not unregistering KVO observer before dealloc.

     If support for weak properties is needed or observing arbitrary or unknown relationships in the
     ownership tree, `rx_observeWeakly` is the preferred option.

     - parameter keyPath: Key path of property names to observe.
     - parameter options: KVO mechanism notification options.
     - parameter retainSelf: Retains self during observation if set `true`.
     - returns: Observable sequence of objects on `keyPath`.
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func rx_observe<E>(type: E.Type, _ keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial], retainSelf: Bool = true) -> Observable<E?> {
        return KVOObservable(object: self, keyPath: keyPath, options: options, retainTarget: retainSelf).asObservable()
    }


    /**
    Observes values on `keyPath` starting from `self` with `options` and retains `self` if `retainSelf` is set.
    
    `rx_observe` is just a simple and performant wrapper around KVO mechanism.
    
    * it can be used to observe paths starting from `self` or from ancestors in ownership graph (`retainSelf = false`)
    * it can be used to observe paths starting from descendants in ownership graph (`retainSelf = true`)
    * the paths have to consist only of `strong` properties, otherwise you are risking crashing the system by not unregistering KVO observer before dealloc.
    
    If support for weak properties is needed or observing arbitrary or unknown relationships in the
    ownership tree, `rx_observeWeakly` is the preferred option.
    
    - parameter keyPath: Key path of property names to observe.
    - parameter options: KVO mechanism notification options.
    - parameter retainSelf: Retains self during observation if set `true`.
    - returns: Observable sequence of objects on `keyPath`.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    @available(*, deprecated=2.0.0, message="Please use version that takes type as first argument `rx_observe<Element>(type: Element.Type, _ keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial], retainSelf: Bool = true) -> Observable<Element?>`")
    public func rx_observe<Element>(keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial], retainSelf: Bool = true) -> Observable<Element?> {
        return KVOObservable(object: self, keyPath: keyPath, options: options, retainTarget: retainSelf).asObservable()
    }

}

#if !DISABLE_SWIZZLING
// KVO
extension NSObject {
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `rx_observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     - parameter keyPath: Key path of property names to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func rx_observeWeakly<E>(type: E.Type, _ keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial]) -> Observable<E?> {
        return observeWeaklyKeyPathFor(self, keyPath: keyPath, options: options)
            .map { n in
                return n as? E
            }
    }

    /**
    Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.
    
    It can be used in all cases where `rx_observe` can be used and additionally
    
    * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
    * it can be used to observe `weak` properties
    
    **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**
    
    - parameter keyPath: Key path of property names to observe.
    - parameter options: KVO mechanism notification options.
    - returns: Observable sequence of objects on `keyPath`.
    */
    @available(*, deprecated=2.0.0, message="Please use version that takes type as first argument `rx_observeWeakly<Element>(type: Element.Type, keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial]) -> Observable<Element?>`")
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func rx_observeWeakly<Element>(keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial]) -> Observable<Element?> {
        return observeWeaklyKeyPathFor(self, keyPath: keyPath, options: options)
            .map { n in
                return n as? Element
            }
    }
}
#endif

// Dealloc
extension NSObject {
    
    /**
    Observable sequence of object deallocated events.
    
    After object is deallocated one `()` element will be produced and sequence will immediately complete.
    
    - returns: Observable sequence of object deallocated events.
    */
    public var rx_deallocated: Observable<Void> {
        return rx_synchronized {
            if let subject = objc_getAssociatedObject(self, &deallocatedSubjectContext) as? ReplaySubject<Void> {
                return subject
            }
            else {
                let subject = ReplaySubject<Void>.create(bufferSize: 1)
                let deinitAction = DeinitAction {
                    subject.on(.Next())
                    subject.on(.Completed)
                }
                objc_setAssociatedObject(self, &deallocatedSubjectContext, subject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                objc_setAssociatedObject(self, &deallocatedSubjectTriggerContext, deinitAction, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return subject
            }
        }
    }

#if !DISABLE_SWIZZLING
    
    /**
    Observable sequence of object deallocating events.
    
    When `dealloc` message is sent to `self` one `()` element will be produced and after object is deallocated sequence
    will immediately complete.
    
    - returns: Observable sequence of object deallocating events.
    */
    public var rx_deallocating: Observable<Void> {
        return rx_synchronized {
            if let subject = objc_getAssociatedObject(self, &deallocatingSubjectContext) as? ReplaySubject<Void> {
                return subject
            }
            else {
                let subject = ReplaySubject<Void>.create(bufferSize: 1)
                objc_setAssociatedObject(
                    self,
                    &deallocatingSubjectContext,
                    subject,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )

                let proxy = Deallocating {
                    subject.on(.Next())
                }

                let deinitAction = DeinitAction {
                    subject.on(.Completed)
                }

                objc_setAssociatedObject(self,
                    RXDeallocatingAssociatedAction,
                    proxy,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                objc_setAssociatedObject(self,
                    &deallocatingSubjectTriggerContext,
                    deinitAction,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )

                RX_ensure_deallocating_swizzled(self.dynamicType)
                return subject
            }
        }
    }
#endif
}
