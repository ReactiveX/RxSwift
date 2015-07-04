//
//  DelegateProxyType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

// `DelegateProxyType` protocol enables using both normal delegates and Rx observables with
// views that can have only one delegate/datasource registered.
//
// `Proxys` store information about observers, subscriptions and delegates
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
public protocol DelegateProxyType : Disposable {
    // tried, it didn't work out
    // typealias View
    
    static func createProxyForView(view: UIView) -> Self
    
    // tried using `Self` instead of Any object, didn't work out
    static func getProxyForView(view: UIView) -> Self?
    static func setProxyToView(view: UIView, proxy: AnyObject)
    
    func setDelegate(delegate: AnyObject?)
    func getDelegate() -> AnyObject?
    
    var isDisposable: Bool { get }
}

struct ProxyDisposablePair<B> {
    let proxy: B
    let disposable: Disposable
}

func performOnInstalledProxy<B: DelegateProxyType, R>(view: UIView, actionOnProxy: (B) -> R) -> R {
    MainScheduler.ensureExecutingOnScheduler()
    
    let maybeProxy: B? = B.getProxyForView(view)
    
    let proxy: B
    if maybeProxy != nil {
        proxy = maybeProxy!
    }
    else {
        proxy = B.createProxyForView(view)
        B.setProxyToView(view, proxy: proxy)
        assert(B.getProxyForView(view) === proxy, "Proxy is not the same")
    }
    
    assert(B.getProxyForView(view) !== nil, "There should be proxy registered.")
    
    return actionOnProxy(proxy)
}

func installDelegateOnProxy<B: DelegateProxyType>(view: UIView, delegate: AnyObject) -> ProxyDisposablePair<B> {
    return performOnInstalledProxy(view) { (proxy: B) in
        assert(proxy.getDelegate() === nil, "There is already a set delegate \(proxy.getDelegate())")
        
        proxy.setDelegate(delegate)
        
        assert(proxy.getDelegate() === delegate, "Setting of delegate failed")
        
        let result = ProxyDisposablePair(proxy: proxy, disposable: AnonymousDisposable {
            MainScheduler.ensureExecutingOnScheduler()
            
            assert(proxy.getDelegate() === delegate, "Delegate was changed from time it was first set. Current \(proxy.getDelegate()), and it should have been \(proxy)")
            
            proxy.setDelegate(nil)
            
            if proxy.isDisposable {
                proxy.dispose()
            }
        })
        
        return result
    }
}

func createObservableUsingDelegateProxy<B: DelegateProxyType, Element, DisposeKey>(view: UIView,
    addObserver: (B, ObserverOf<Element>) -> DisposeKey,
    removeObserver: (B, DisposeKey) -> ())
    -> Observable<Element> {
    
    return AnonymousObservable { observer in
        return performOnInstalledProxy(view) { (proxy: B) in
            let key = addObserver(proxy, observer)
            
            return AnonymousDisposable {
                MainScheduler.ensureExecutingOnScheduler()
                
                removeObserver(proxy, key)
                
                if proxy.isDisposable {
                    proxy.dispose()
                }
            }
        }
    }
}

func subscribeObservableUsingDelegateProxyAndDataSource<B: DelegateProxyType, Element>(view: UIView, dataSource: AnyObject, binding: (B, Event<Element>) -> Void)
    -> Observable<Element> -> Disposable {
    return { source  in
        let result: ProxyDisposablePair<B> = installDelegateOnProxy(view, dataSource)
        let proxy = result.proxy
        
        let subscription = source.subscribe(AnonymousObserver { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            assert(proxy === B.getProxyForView(view), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(B.getProxyForView(view))")
            
            binding(proxy, event)
        })
            
        return StableCompositeDisposable.create(subscription, result.disposable)
    }
}
