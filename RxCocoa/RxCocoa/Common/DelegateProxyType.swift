//
//  DelegateProxyType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

// `DelegateProxyType` protocol enables using both normal delegates and Rx observables with
// views that can have only one delegate/datasource registered.
//
// `Proxies` store information about observers, subscriptions and delegates
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
  | Delegate proxy : DelegateProxyType        +-----+---->  Observable<T1>
  |                , UIScrollViewDelegate     |     |
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
  |                                           |
  +-------------------------------------------+                           

*/
// Since RxCocoa needs to automagically create those Proxys 
// ..and because views that have delegates can be hierarchical
//
//      UITableView : UIScrollView : UIView
//
// .. and corresponding delegates are also hierarchical
//
//      UITableViewDelegate : UIScrollViewDelegate : NSObject
//
// .. and sometimes there can be only one proxy/delegate registered,
// every view has a corresponding delegate virtual factory method.
//
// In case of UITableView / UIScrollView, there is
//
// ```
// extensions UIScrollView {
//     public func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
//         return RxScrollViewDelegateProxy(view: self)
//     }
//
//     ....
// ```
//
// and override in UITableView
//
//```
// extension UITableView {
//     public override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
//         ....
//```
//
public protocol DelegateProxyType : AnyObject {
    // Creates new proxy for target object.
    static func createProxyForObject(object: AnyObject) -> Self
   
    // There can be only one registered proxy per object
    // These functions control that.
    static func assignProxy(proxy: AnyObject, toObject object: AnyObject)
    static func getAssignedProxyFor(object: AnyObject) -> Self?
    
    // Set/Get current delegate for object
    static func getCurrentDelegateFor(object: AnyObject) -> AnyObject?
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject)
    
    // Set/Get current delegate on proxy
    func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool)
    func getForwardToDelegate() -> AnyObject?
}

// future extensions :)

// this will install proxy if needed
func proxyForObject<P: DelegateProxyType>(object: AnyObject) -> P {
    MainScheduler.ensureExecutingOnScheduler()
    
    let maybeProxy = P.getAssignedProxyFor(object)
    
    let proxy: P
    if maybeProxy == nil {
        proxy = P.createProxyForObject(object)
        P.assignProxy(proxy, toObject: object)
        assert(P.getAssignedProxyFor(object) === proxy)
    }
    else {
        proxy = maybeProxy!
    }
    
    let currentDelegate: AnyObject? = P.getCurrentDelegateFor(object)
    
    if currentDelegate !== proxy {
        proxy.setForwardToDelegate(currentDelegate, retainDelegate: false)
        P.setCurrentDelegate(proxy, toObject: object)
        assert(P.getCurrentDelegateFor(object) === proxy)
        assert(proxy.getForwardToDelegate() === currentDelegate)
    }
        
    return proxy
}

func installDelegate<P: DelegateProxyType>(proxy: P, delegate: AnyObject, retainDelegate: Bool, onProxyForObject object: AnyObject) -> Disposable {
    
    //assert(proxy === proxyForObject(object))
    assert(proxy.getForwardToDelegate() === nil, "There is already a set delegate \(proxy.getForwardToDelegate())")
    
    proxy.setForwardToDelegate(delegate, retainDelegate: retainDelegate)
    
    // refresh properties after delegate is set
    // some views like UITableView cache `respondsToSelector`
    P.setCurrentDelegate(nil, toObject: object)
    P.setCurrentDelegate(proxy, toObject: object)
    
    assert(proxy.getForwardToDelegate() === delegate, "Setting of delegate failed")
    
    return AnonymousDisposable {
        MainScheduler.ensureExecutingOnScheduler()
        
        assert(proxy.getForwardToDelegate() === delegate, "Delegate was changed from time it was first set. Current \(proxy.getForwardToDelegate()), and it should have been \(proxy)")
        
        proxy.setForwardToDelegate(nil, retainDelegate: retainDelegate)
    }
}

func proxyObservableForObject<P: DelegateProxyType, Element, DisposeKey>(object: AnyObject,
    addObserver: (P, ObserverOf<Element>) -> DisposeKey,
    removeObserver: (P, DisposeKey) -> ())
    -> Observable<Element> {
    
    return AnonymousObservable { observer in
        let proxy: P = proxyForObject(object)
        let key = addObserver(proxy, observer)
        
        return AnonymousDisposable {
            MainScheduler.ensureExecutingOnScheduler()
            
            removeObserver(proxy, key)
        }
    }
}

func setProxyDataSourceForObject<P: DelegateProxyType, Element>(object: AnyObject, dataSource: AnyObject, retainDataSource: Bool, binding: (P, Event<Element>) -> Void)
    -> Observable<Element> -> Disposable {
    return { source  in
        let proxy: P = proxyForObject(object)
        let disposable = installDelegate(proxy, dataSource, retainDataSource, onProxyForObject: object)
        
        let subscription = source.subscribe(AnonymousObserver { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            assert(proxy === P.getCurrentDelegateFor(object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(P.getCurrentDelegateFor(object))")
            
            binding(proxy, event)
        })
            
        return StableCompositeDisposable.create(subscription, disposable)
    }
}
