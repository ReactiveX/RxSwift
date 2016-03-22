//
//  NSObject+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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
            if let deallocObservable = objc_getAssociatedObject(self, &deallocatedSubjectContext) as? DeallocObservable {
                return deallocObservable._subject
            }

            let deallocObservable = DeallocObservable()

            objc_setAssociatedObject(self, &deallocatedSubjectContext, deallocObservable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return deallocObservable._subject
        }
    }

#if !DISABLE_SWIZZLING

    /**
     Observable sequence of message arguments that completes when object is deallocated.

     In case an error occurs sequence will fail with `RxCocoaObjCRuntimeError`.
     
     In case some argument is `nil`, instance of `NSNull()` will be sent.

     - returns: Observable sequence of object deallocating events.
     */
    public func rx_sentMessage(selector: Selector) -> Observable<[AnyObject]> {
        return rx_synchronized {
            // in case of dealloc selector replay subject behavior needs to be used
            if selector == deallocSelector {
                return rx_deallocating.map { _ in [] }
            }

            let rxSelector = RX_selector(selector)
            let selectorReference = RX_reference_from_selector(rxSelector)

            let subject: MessageSentObservable
            if let existingSubject = objc_getAssociatedObject(self, selectorReference) as? MessageSentObservable {
                subject = existingSubject
            }
            else {
                subject = MessageSentObservable()
                objc_setAssociatedObject(
                    self,
                    selectorReference,
                    subject,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }

            if subject.isActive {
                return subject.asObservable()
            }

            var error: NSError?
            let targetImplementation = RX_ensure_observing(self, selector, &error)
            if targetImplementation == nil {
                return Observable.error(error?.rxCocoaErrorForTarget(self) ?? RxCocoaError.Unknown)
            }

            subject.targetImplementation = targetImplementation
            return subject.asObservable()
        }
    }

    /**
    Observable sequence of object deallocating events.
    
    When `dealloc` message is sent to `self` one `()` element will be produced and after object is deallocated sequence
    will immediately complete.
     
    In case an error occurs sequence will fail with `RxCocoaObjCRuntimeError`.
    
    - returns: Observable sequence of object deallocating events.
    */
    public var rx_deallocating: Observable<()> {
        return rx_synchronized {

            let subject: DeallocatingObservable
            if let existingSubject = objc_getAssociatedObject(self, rxDeallocatingSelectorReference) as? DeallocatingObservable {
                subject = existingSubject
            }
            else {
                subject = DeallocatingObservable()
                objc_setAssociatedObject(
                    self,
                    rxDeallocatingSelectorReference,
                    subject,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }

            if subject.isActive {
                return subject.asObservable()
            }

            var error: NSError?
            let targetImplementation = RX_ensure_observing(self, deallocSelector, &error)
            if targetImplementation == nil {
                return Observable.error(error?.rxCocoaErrorForTarget(self) ?? RxCocoaError.Unknown)
            }

            subject.targetImplementation = targetImplementation
            return subject.asObservable()
        }
    }
#endif
}

let deallocSelector = NSSelectorFromString("dealloc")
let rxDeallocatingSelector = RX_selector(deallocSelector)
let rxDeallocatingSelectorReference = RX_reference_from_selector(rxDeallocatingSelector)

extension NSObject {
    func rx_synchronized<T>(@noescape action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
}

extension NSObject {
    /**
     Helper to make sure that `Observable` returned from `createCachedObservable` is only created once.
     This is important because there is only one `target` and `action` properties on `NSControl` or `UIBarButtonItem`.
     */
    func rx_lazyInstanceObservable<T: AnyObject>(key: UnsafePointer<Void>, createCachedObservable: () -> T) -> T {
        if let value = objc_getAssociatedObject(self, key) {
            return value as! T
        }
        
        let observable = createCachedObservable()
        
        objc_setAssociatedObject(self, key, observable, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return observable
    }
}