//
//  DelegateProxyType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

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
    static func createProxyForObject(object: AnyObject) -> AnyObject
   
    // There can be only one registered proxy per object
    // These functions control that.
    static func assignedProxyFor(object: AnyObject) -> AnyObject?
    static func assignProxy(proxy: AnyObject, toObject object: AnyObject)
    
    // Set/Get current delegate for object
    static func currentDelegateFor(object: AnyObject) -> AnyObject?
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject)
    
    // Set/Get current delegate on proxy
    func forwardToDelegate() -> AnyObject?
    func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool)
}

// future extensions :)

// this will install proxy if needed
public func proxyForObject<P: DelegateProxyType>(object: AnyObject) -> P {
    MainScheduler.ensureExecutingOnScheduler()
    
    let maybeProxy = P.assignedProxyFor(object) as? P
    
    let proxy: P
    if maybeProxy == nil {
        proxy = P.createProxyForObject(object) as! P
        P.assignProxy(proxy, toObject: object)
        assert(P.assignedProxyFor(object) === proxy)
    }
    else {
        proxy = maybeProxy!
    }
    
    let currentDelegate: AnyObject? = P.currentDelegateFor(object)
    
    if currentDelegate !== proxy {
        proxy.setForwardToDelegate(currentDelegate, retainDelegate: false)
        P.setCurrentDelegate(proxy, toObject: object)
        assert(P.currentDelegateFor(object) === proxy)
        assert(proxy.forwardToDelegate() === currentDelegate)
    }
        
    return proxy
}

func installDelegate<P: DelegateProxyType>(proxy: P, delegate: AnyObject, retainDelegate: Bool, onProxyForObject object: AnyObject) -> Disposable {
    weak var weakDelegate: AnyObject? = delegate
    
    assert(proxy.forwardToDelegate() === nil, "There is already a set delegate \(proxy.forwardToDelegate())")
    
    proxy.setForwardToDelegate(delegate, retainDelegate: retainDelegate)
    
    // refresh properties after delegate is set
    // some views like UITableView cache `respondsToSelector`
    P.setCurrentDelegate(nil, toObject: object)
    P.setCurrentDelegate(proxy, toObject: object)
    
    assert(proxy.forwardToDelegate() === delegate, "Setting of delegate failed")
    
    return AnonymousDisposable {
        MainScheduler.ensureExecutingOnScheduler()
        
        let delegate: AnyObject? = weakDelegate
        
        assert(delegate == nil || proxy.forwardToDelegate() === delegate, "Delegate was changed from time it was first set. Current \(proxy.forwardToDelegate()), and it should have been \(proxy)")
        
        proxy.setForwardToDelegate(nil, retainDelegate: retainDelegate)
    }
}

extension ObservableType {
    func subscribeProxyDataSourceForObject<P: DelegateProxyType>(object: AnyObject, dataSource: AnyObject, retainDataSource: Bool, binding: (P, Event<E>) -> Void)
        -> Disposable {
        let proxy: P = proxyForObject(object)
        let disposable = installDelegate(proxy, delegate: dataSource, retainDelegate: retainDataSource, onProxyForObject: object)
        
        // we should never let the subscriber to complete because it should retain data source
        let source = sequenceOf(self.asObservable(), never()) as Observable<Observable<E>>
        let subscription = source.concat().subscribe { (event: Event<E>) in
            MainScheduler.ensureExecutingOnScheduler()
            
            assert(proxy === P.currentDelegateFor(object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(P.currentDelegateFor(object))")
            
            binding(proxy, event)
            
            switch event {
            case .Error(let error):
                bindingErrorToInterface(error)
                disposable.dispose()
            case .Completed:
                disposable.dispose()
            default:
                break
            }
        }
            
        return StableCompositeDisposable.create(subscription, disposable)
    }
}
