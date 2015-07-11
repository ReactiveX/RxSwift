//
//  NSObject+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

var deallocatedSubjectContext: UInt8 = 0

// KVO
//
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
extension NSObject {
    // Observes values of `path` starting from `self` with `.Initial | .New` options.
    // Retains `self` while observing.
    public func rx_observe<Element>(path: String) -> Observable<Element?> {
        return KVOObservable(object: self, path: path, options: .Initial | .New, retainTarget: true)
    }

    // Observes values of `path` starting from `self` with `options`
    // Retains `self` while observing.
    public func rx_observe<Element>(path: String, options: NSKeyValueObservingOptions) -> Observable<Element?> {
        return KVOObservable(object: self, path: path, options: options, retainTarget: true)
    }

    // Observes values of `path` starting from `self` with `options` and retainsSelf if `retainSelf` is set.
    public func rx_observe<Element>(path: String, options: NSKeyValueObservingOptions, retainSelf: Bool) -> Observable<Element?> {
        return KVOObservable(object: self, path: path, options: options, retainTarget: retainSelf)
    }
}

extension NSObject {
    // Sends next element when object is deallocated and immediately completes sequence.
    public var rx_deallocated: Observable<Void> {
        return rx_synchronized {
            if let subject = objc_getAssociatedObject(self, &deallocatedSubjectContext) as? DeallocSubject<Void> {
                return subject
            }
            else {
                let subject = createDeallocDisposable { s in
                    sendNext(s, ())
                    sendCompleted(s)
                }
                objc_setAssociatedObject(self, &deallocatedSubjectContext, subject, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
                return subject
            }
        }
    }
}