//
//  DelegateProxyType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

/**
`DelegateProxyType` protocol enables using both normal delegates and Rx observable sequences with
views that can have only one delegate/datasource registered.

`Proxies` store information about observers, subscriptions and delegates
for specific views.

Type implementing `DelegateProxyType` should never be initialized directly.

To fetch initialized instance of type implementing `DelegateProxyType`, `proxyForObject` method
should be used.

This is more or less how it works.



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
                  |                                     +---->  Observable<T3>
                  |                                     |                     
                  | forwards events                     |
                  | to custom delegate                  |
                  |                                     v                     
      +-----------v-------------------------------+                           
      |                                           |                           
      | Custom delegate (UIScrollViewDelegate)    |                           
      |                                           |
      +-------------------------------------------+                           


Since RxCocoa needs to automagically create those Proxys
..and because views that have delegates can be hierarchical

UITableView : UIScrollView : UIView

.. and corresponding delegates are also hierarchical

UITableViewDelegate : UIScrollViewDelegate : NSObject

.. and sometimes there can be only one proxy/delegate registered,
every view has a corresponding delegate virtual factory method.

In case of UITableView / UIScrollView, there is

    extension UIScrollView {
        public func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
            return RxScrollViewDelegateProxy(parentObject: self)
        }
    ....


and override in UITableView

    extension UITableView {
        public override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        ....


*/
public protocol DelegateProxyType : AnyObject {
    /**
    Creates new proxy for target object.
    */
    static func createProxyForObject(object: AnyObject) -> AnyObject
   
    /**
    Returns assigned proxy for object.
    
    - parameter object: Object that can have assigned delegate proxy.
    - returns: Assigned delegate proxy or `nil` if no delegate proxy is assigned.
    */
    static func assignedProxyFor(object: AnyObject) -> AnyObject?
    
    /**
    Assigns proxy to object.
    
    - parameter object: Object that can have assigned delegate proxy.
    - parameter proxy: Delegate proxy object to assign to `object`.
    */
    static func assignProxy(proxy: AnyObject, toObject object: AnyObject)
    
    /**
    Returns designated delegate property for object.
    
    Objects can have multiple delegate properties.
    
    Each delegate property needs to have it's own type implementing `DelegateProxyType`.
    
    - parameter object: Object that has delegate property.
    - returns: Value of delegate property.
    */
    static func currentDelegateFor(object: AnyObject) -> AnyObject?

    /**
    Sets designated delegate property for object.
    
    Objects can have multiple delegate properties.
    
    Each delegate property needs to have it's own type implementing `DelegateProxyType`.
    
    - parameter toObject: Object that has delegate property.
    - parameter delegate: Delegate value.
    */
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject)
    
    /**
    Returns reference of normal delegate that receives all forwarded messages
    through `self`.
    
    - returns: Value of reference if set or nil.
    */
    func forwardToDelegate() -> AnyObject?

    /**
    Sets reference of normal delegate that receives all forwarded messages
    through `self`.
    
    - parameter forwardToDelegate: Reference of delegate that receives all messages through `self`.
    - parameter retainDelegate: Should `self` retain `forwardToDelegate`.
    */
    func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool)
}

@available(*, deprecated=2.5, renamed="DelegateProxyType.proxyForObject", message="You can just use normal static protocol extension. E.g. `RxScrollViewDelegateProxy.proxyForObject`")
public func proxyForObject<P: DelegateProxyType>(type: P.Type, _ object: AnyObject) -> P {
    return P.proxyForObject(object)
}

extension DelegateProxyType {
    /**
     Returns existing proxy for object or installs new instance of delegate proxy.

     - parameter object: Target object on which to install delegate proxy.
     - returns: Installed instance of delegate proxy.


         extension UISearchBar {

             public var rx_delegate: DelegateProxy {
                return RxSearchBarDelegateProxy.proxyForObject(self)
             }

             public var rx_text: ControlProperty<String> {
                 let source: Observable<String> = self.rx_delegate.observe(#selector(UISearchBarDelegate.searchBar(_:textDidChange:)))
                 ...
             }
         }
    */
    public static func proxyForObject(object: AnyObject) -> Self {
        MainScheduler.ensureExecutingOnScheduler()

        let maybeProxy = Self.assignedProxyFor(object) as? Self

        let proxy: Self
        if maybeProxy == nil {
            proxy = Self.createProxyForObject(object) as! Self
            Self.assignProxy(proxy, toObject: object)
            assert(Self.assignedProxyFor(object) === proxy)
        }
        else {
            proxy = maybeProxy!
        }

        let currentDelegate: AnyObject? = Self.currentDelegateFor(object)

        if currentDelegate !== proxy {
            proxy.setForwardToDelegate(currentDelegate, retainDelegate: false)
            Self.setCurrentDelegate(proxy, toObject: object)
            assert(Self.currentDelegateFor(object) === proxy)
            assert(proxy.forwardToDelegate() === currentDelegate)
        }
        
        return proxy
    }

    /**
    Sets forward delegate for `DelegateProxyType` associated with a specific object and return disposable that can be used to unset the forward to delegate.
    Using this method will also make sure that potential original object cached selectors are cleared and will report any accidental forward delegate mutations.
     
    - parameter forwardDelegate: Delegate object to set.
    - parameter retainDelegate: Retain `forwardDelegate` while it's being set.
    - parameter onProxyForObject: Object that has `delegate` property.
    - returns: Disposable object that can be used to clear forward delegate.
    */
    public static func installForwardDelegate(forwardDelegate: AnyObject, retainDelegate: Bool, onProxyForObject object: AnyObject) -> Disposable {
        weak var weakForwardDelegate: AnyObject? = forwardDelegate

        let proxy = Self.proxyForObject(object)
        
        assert(proxy.forwardToDelegate() === nil, "This is a feature to warn you that there is already a delegate (or data source) set somewhere previously. The action you are trying to perform will clear that delegate (data source) and that means that some of your features that depend on that delegate (data source) being set will likely stop working.\n" +
            "If you are ok with this, try to set delegate (data source) to `nil` in front of this operation.\n" +
            " This is the source object value: \(object)\n" +
            " This this the original delegate (data source) value: \(proxy.forwardToDelegate()!)\n" +
            "Hint: Maybe delegate was already set in xib or storyboard and now it's being overwritten in code.\n")

        proxy.setForwardToDelegate(forwardDelegate, retainDelegate: retainDelegate)
        
        // refresh properties after delegate is set
        // some views like UITableView cache `respondsToSelector`
        Self.setCurrentDelegate(nil, toObject: object)
        Self.setCurrentDelegate(proxy, toObject: object)
        
        assert(proxy.forwardToDelegate() === forwardDelegate, "Setting of delegate failed")
        
        return AnonymousDisposable {
            MainScheduler.ensureExecutingOnScheduler()
            
            let delegate: AnyObject? = weakForwardDelegate
            
            assert(delegate == nil || proxy.forwardToDelegate() === delegate, "Delegate was changed from time it was first set. Current \(proxy.forwardToDelegate()), and it should have been \(proxy)")
            
            proxy.setForwardToDelegate(nil, retainDelegate: retainDelegate)
        }
    }
}

extension ObservableType {
    func subscribeProxyDataSourceForObject<P: DelegateProxyType>(object: AnyObject, dataSource: AnyObject, retainDataSource: Bool, binding: (P, Event<E>) -> Void)
        -> Disposable {
        let proxy = P.proxyForObject(object)
        let disposable = P.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)

        let subscription = self.asObservable()
            // source can never end, otherwise it would release the subscriber
            .concat(Observable.never())
            .subscribe { [weak object] (event: Event<E>) in
                MainScheduler.ensureExecutingOnScheduler()

                if let object = object {
                    assert(proxy === P.currentDelegateFor(object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(P.currentDelegateFor(object))")
                }
                
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
