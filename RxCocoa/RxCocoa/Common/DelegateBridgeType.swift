//
//  DelegateBridgeType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

// `DelegateBridgeType` protocol enables using both normal delegates and Rx observables with
// views that can have only one delegate/datasource registered.
//
// `Bridges` store information about observers, subscriptions and delegates
// for specific views.
//
//
// This is more or less how it works.
//
/*

  +-------------------------------------------+                           
  |                                           |                           
  | UIView subclass (UIScrollView)            |                           
  |                                           |                           
  +-----------+-------------------------------+                           
              |                                                           
              | Delegate                                                  
              |                                                           
              |                                                           
  +-----------v-------------------------------+                           
  |                                           |                           
  | Delegate bridge : DelegateBridgeType      +-----+---->  Observable<T1>
  |                 , UIScrollViewDelegate    |     |
  +-----------+-------------------------------+     +---->  Observable<T2>
              |                                     |                     
              | rx_bind(delegate) -> Disposable     +---->  Observable<T3>
              |                                     |                     
              | proxies events                      |                     
              |                                     |                     
              |                                     v                     
  +-----------v-------------------------------+                           
  |                                           |                           
  | Custom delegate (UIScrollViewDelegate)    |                           
  |     or RxScrollViewDelegate               |
  +-------------------------------------------+                           

*/
// Since RxCocoa needs to automagically create those bridges 
// ..and because views that have delegates can be hierarchical
//
//      UITableView : UIScrollView : UIView
//
// .. and corresponding delegates are also hierarchical
//
//      UITableViewDelegate : UIScrollViewDelegate : NSObject
//
// .. and sometimes there can be only one bridge/delegate registered,
// every view has a corresponding delegate virtual factory method.
//
// In case of UITableView / UIScrollView, there is
//
// ```
// extensions UIScrollView {
//     public func rx_createDelegateBridge() -> RxScrollViewDelegateBridge {
//         return RxScrollViewDelegateBridge(view: self)
//     }
//
//     ....
// ```
//
// and override in UITableView
//
//```
// extension UITableView {
//     public override func rx_createDelegateBridge() -> RxScrollViewDelegateBridge {
//         ....
//```
//
// =============================================================================
//
// But there is more :)
//
// Unfortunately, Swift generic classes can't inherit from `UI[UKitView]Delegate` protocols.
// That means that one would need to create its own swift proxy class to implement generic
// data source or delegates.
//
// But since RxCocoa already has Swift classes that are bridges for ObjC protocols, why not use
// them and enable generic Swift data sources and delegates.
//
// That's exactly what `Rx[UIKitView]DelegateType` set of protocols are for.
//
// Since swift bridge classes already exist, RxCocoa project defines it's own set of delegates.
// They implement exactly same methods like their original UIKit mirror delegates.
// In that case, if you already have some delegate logic that implements `[UIKitView]Delegate`
// it should be pretty straightforward to incorporate it with RxCocoa project.
//
// =============================================================================
//
// But there is more :)
//
// It would be kind of impolite to require users to fiddle with their existing working 
// code, and now suddenly have to use `Rx[UIKitView]DelegateType` set of protocols.
//
// That's why for each Rx protocol there is already a corresponding converter class
// that converts from `[UIView]Delegate` to `Rx[UIView]DelegateType`.
//
// E.g. RxScrollViewDelegateConverter is adapter for UIScrollViewDelegate
//
// =============================================================================
//
// But there is more :)
//
// In case you want to use `Rx[UIView]DelegateType` protocols, Swift unfortunately doesn't 
// support optional methods in protocols.
//
// That's why for each `Rx[UIView]DelegateType` protocol there is already 
// `Rx[UIKitView]NopDelegate` implementation provided.
// 
// It enables you to define just those methods that you really care about in your delegate
// implementation.
// Methods that aren't overriden will use default implementation from NopDelegate that
// don't do anything.
//
public protocol DelegateBridgeType : Disposable {
    // tried, it didn't work out
    // typealias View
    
    static func createBridgeForView(view: UIView) -> Self
    
    // tried using `Self` instead of Any object, didn't work out
    static func getBridgeForView(view: UIView) -> Self?
    static func setBridgeToView(view: UIView, bridge: AnyObject)
    
    func setDelegate(delegate: AnyObject?)
    func getDelegate() -> AnyObject?
    
    var isDisposable: Bool { get }
}

struct BridgeDisposablePair<B> {
    let bridge: B
    let disposable: Disposable
}

func performOnInstalledBridge<B: DelegateBridgeType, R>(view: UIView, actionOnBridge: (B) -> R) -> R {
    MainScheduler.ensureExecutingOnScheduler()
    
    let maybeBridge: B? = B.getBridgeForView(view)
    
    let bridge: B
    if maybeBridge != nil {
        bridge = maybeBridge!
    }
    else {
        bridge = B.createBridgeForView(view)
        B.setBridgeToView(view, bridge: bridge)
        assert(B.getBridgeForView(view) === bridge, "Bridge is not the same")
    }
    
    assert(B.getBridgeForView(view) !== nil, "There should be bridge registered.")
    
    return actionOnBridge(bridge)
}

func installDelegateOnBridge<B: DelegateBridgeType>(view: UIView, delegate: AnyObject) -> BridgeDisposablePair<B> {
    return performOnInstalledBridge(view) { (bridge: B) in
        assert(bridge.getDelegate() === nil, "There is already a set delegate \(bridge.getDelegate())")
        
        bridge.setDelegate(delegate)
        
        assert(bridge.getDelegate() === delegate, "Setting of delegate failed")
        
        let result = BridgeDisposablePair(bridge: bridge, disposable: AnonymousDisposable {
            MainScheduler.ensureExecutingOnScheduler()
            
            assert(bridge.getDelegate() === delegate, "Delegate was changed from time it was first set. Current \(bridge.getDelegate()), and it should have been \(bridge)")
            
            bridge.setDelegate(nil)
            
            if bridge.isDisposable {
                bridge.dispose()
            }
        })
        
        return result
    }
}

func createObservableUsingDelegateBridge<B: DelegateBridgeType, Element, DisposeKey>(view: UIView,
    addObserver: (B, ObserverOf<Element>) -> DisposeKey,
    removeObserver: (B, DisposeKey) -> ())
    -> Observable<Element> {
    
    return AnonymousObservable { observer in
        return performOnInstalledBridge(view) { (bridge: B) in
            let key = addObserver(bridge, observer)
            
            return AnonymousDisposable {
                MainScheduler.ensureExecutingOnScheduler()
                
                removeObserver(bridge, key)
                
                if bridge.isDisposable {
                    bridge.dispose()
                }
            }
        }
    }
}

func subscribeObservableUsingDelegateBridgeAndDataSource<B: DelegateBridgeType, Element>(view: UIView, dataSource: AnyObject, binding: (B, Event<Element>) -> Void)
    -> Observable<Element> -> Disposable {
    return { source  in
        let result: BridgeDisposablePair<B> = installDelegateOnBridge(view, dataSource)
        let bridge = result.bridge
        
        let subscription = source.subscribe(AnonymousObserver { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            assert(bridge === B.getBridgeForView(view), "Bridge changed from the time it was first set.\nOriginal: \(bridge)\nExisting: \(B.getBridgeForView(view))")
            
            binding(bridge, event)
        })
            
        return StableCompositeDisposable.create(subscription, bridge)
    }
}
