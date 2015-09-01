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

// KVO is a tricky mechanism.
//
// When observing child in a ownership hierarchy, usually retaining observing target is wanted behavior.
// When observing parent in a ownership hierarchy, usually retaining target isn't wanter behavior.
//
// KVO with weak references is especially tricky. For it to work, some kind of swizzling is required.
// That can be done by
// * replacing object class dynamically (like KVO does)
// * by swizzling `dealloc` method on all instances for a class.
// * some third method ...
//
// Both approaches can fail in certain scenarios:
// * problems arise when swizzlers return original object class (like KVO does when nobody is observing)
// * Problems can arise because replacing dealloc method isn't atomic operation (get implementation,
//   set implementation).
//
// Second approach is chosen. It can fail in case there are multiple libraries dynamically trying
// to replace dealloc method. In case that isn't the case, it should be ok.
//

// KVO
extension NSObject {

    // Observes values on `keyPath` starting from `self` with `options` and retainsSelf if `retainSelf` is set.
    public func rx_observe<Element>(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New.union(NSKeyValueObservingOptions.Initial), retainSelf: Bool = true) -> Observable<Element?> {
        return KVOObservable(object: self, keyPath: keyPath, options: options, retainTarget: retainSelf)
    }

}

#if !DISABLE_SWIZZLING
// KVO
extension NSObject {
    
    // Observes values on `keyPath` starting from `self` with `options`
    // Doesn't retain `self` and when `self` is deallocated, completes the sequence.
    public func rx_observeWeakly<Element>(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New.union(NSKeyValueObservingOptions.Initial)) -> Observable<Element?> {
        return observeWeaklyKeyPathFor(self, keyPath: keyPath, options: options)
            .map { n in
                return n as? Element
            }
    }
}
#endif

// Dealloc
extension NSObject {
    // Sends next element when object is deallocated and immediately completes sequence.
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
    // Sends element when object `dealloc` message is sent to `self`.
    // Completes when `self` was deallocated.
    //
    // Has performance penalty, so prefer `rx_deallocated` when ever possible.
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
