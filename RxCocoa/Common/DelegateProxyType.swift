//
//  DelegateProxyType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !os(Linux)

#if !RX_NO_MODULE
import RxSwift
#endif

/**
`DelegateProxyType` protocol enables using both normal delegates and Rx observable sequences with
views that can have only one delegate/datasource registered.

`Proxies` store information about observers, subscriptions and delegates
for specific views.

Type implementing `DelegateProxyType` should never be initialized directly.

To fetch initialized instance of type implementing `DelegateProxyType`, `proxy` method
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

    class RxScrollViewDelegateProxy: DelegateProxy {
        static var factory = DelegateProxyFactory { (parentObject: UIScrollView) in
            RxScrollViewDelegateProxy(parentObject: parentObject)
        }
    }
    ....


and extend it

    RxScrollViewDelegateProxy.extendProxy { (parentObject: UITableView) in
       RxTableViewDelegateProxy(parentObject: parentObject)
    }


*/
public protocol DelegateProxyType : AnyObject {
    associatedtype ParentObject: AnyObject
    associatedtype Delegate: AnyObject
    
    /// DelegateProxy factory. Use 'DelegateProxyFactory.sharedFactory'.
    static var factory: DelegateProxyFactory { get }

    /// Creates new proxy for target object.
    /// Should not call this function directory, use 'DelegateProxy.proxy(for:)'
    static func createProxy(for object: AnyObject) -> AnyObject
    
    /// It is require that enumerate call `register` of the extended DelegateProxy subclasses here.
    static func knownImplementations()

    init(parentObject: ParentObject)

    /// Returns assigned proxy for object.
    ///
    /// - parameter object: Object that can have assigned delegate proxy.
    /// - returns: Assigned delegate proxy or `nil` if no delegate proxy is assigned.
    static func assignedProxy(for object: ParentObject) -> Delegate?

    /// Assigns proxy to object.
    ///
    /// - parameter object: Object that can have assigned delegate proxy.
    /// - parameter proxy: Delegate proxy object to assign to `object`.
    static func assignProxy(_ proxy: Delegate, toObject object: ParentObject)

    /// Returns designated delegate property for object.
    ///
    /// Objects can have multiple delegate properties.
    ///
    /// Each delegate property needs to have it's own type implementing `DelegateProxyType`.
    ///
    /// It's abstract method.
    ///
    /// - parameter object: Object that has delegate property.
    /// - returns: Value of delegate property.
    static func currentDelegate(for object: ParentObject) -> Delegate?

    /// Sets designated delegate property for object.
    ///
    /// Objects can have multiple delegate properties.
    ///
    /// Each delegate property needs to have it's own type implementing `DelegateProxyType`.
    ///
    /// It's abstract method.
    ///
    /// - parameter toObject: Object that has delegate property.
    /// - parameter delegate: Delegate value.
    static func setCurrentDelegate(_ delegate: Delegate?, toObject object: ParentObject)

    /// Returns reference of normal delegate that receives all forwarded messages
    /// through `self`.
    ///
    /// - returns: Value of reference if set or nil.
    func forwardToDelegate() -> Delegate?

    /// Sets reference of normal delegate that receives all forwarded messages
    /// through `self`.
    ///
    /// - parameter forwardToDelegate: Reference of delegate that receives all messages through `self`.
    /// - parameter retainDelegate: Should `self` retain `forwardToDelegate`.
    func setForwardToDelegate(_ forwardToDelegate: Delegate?, retainDelegate: Bool)
}

extension DelegateProxyType {

    /// Store DelegateProxy subclass to factory.
    /// When make 'Rx*DelegateProxy' subclass, call 'Rx*DelegateProxySubclass.register()' 1 time, or use it in DelegateProxyFactory
    /// 'Rx*DelegateProxy' can have one subclass implementation per concrete ParentObject type.
    /// Should call it from concrete DelegateProxy type, not generic.
    public static func register(for parentObjectType: ParentObject.Type) {
        self.factory.extend(with: self, for: parentObjectType)
    }
    
    /// It is require that enumerate call `register` of the extended DelegateProxy subclasses here.
    /// Default is nop
    public static func knownImplementations() {
        
    }
    
    /// Creates new proxy for target object.
    /// Should not call this function directory, use 'DelegateProxy.proxy(for:)'
    public static func createProxy(for object: AnyObject) -> AnyObject {
        return factory.createProxy(for: object)
    }

    /// Returns existing proxy for object or installs new instance of delegate proxy.
    ///
    /// - parameter object: Target object on which to install delegate proxy.
    /// - returns: Installed instance of delegate proxy.
    ///
    ///
    ///     extension Reactive where Base: UISearchBar {
    ///
    ///         public var delegate: DelegateProxy<Base, UISearchBarDelegate> {
    ///            return RxSearchBarDelegateProxy<Base>.proxy(for: base)
    ///         }
    ///
    ///         public var text: ControlProperty<String> {
    ///             let source: Observable<String> = self.delegate.observe(#selector(UISearchBarDelegate.searchBar(_:textDidChange:)))
    ///             ...
    ///         }
    ///     }
    public static func proxy(for object: ParentObject) -> Self {
        MainScheduler.ensureExecutingOnScheduler()

        let maybeProxy = self.assignedProxy(for: object)

        // Type is ideally be `(Self & Delegate)`, but Swift 3.0 doesn't support it.
        let proxy: Delegate
        if let existingProxy = maybeProxy {
            proxy = existingProxy
        }
        else {
            proxy = castOrFatalError(self.createProxy(for: object))
            self.assignProxy(proxy, toObject: object)
            assert(self.assignedProxy(for: object) === proxy)
        }
        let currentDelegate = self.currentDelegate(for: object)
        let delegateProxy: Self = castOrFatalError(proxy)

        if currentDelegate !== delegateProxy {
            delegateProxy.setForwardToDelegate(currentDelegate, retainDelegate: false)
            assert(delegateProxy.forwardToDelegate() === currentDelegate)
            self.setCurrentDelegate(proxy, toObject: object)
            assert(self.currentDelegate(for: object) === proxy)
            assert(delegateProxy.forwardToDelegate() === currentDelegate)
        }

        return delegateProxy
    }

    /// Sets forward delegate for `DelegateProxyType` associated with a specific object and return disposable that can be used to unset the forward to delegate.
    /// Using this method will also make sure that potential original object cached selectors are cleared and will report any accidental forward delegate mutations.
    ///
    /// - parameter forwardDelegate: Delegate object to set.
    /// - parameter retainDelegate: Retain `forwardDelegate` while it's being set.
    /// - parameter onProxyForObject: Object that has `delegate` property.
    /// - returns: Disposable object that can be used to clear forward delegate.
    public static func installForwardDelegate(_ forwardDelegate: Delegate, retainDelegate: Bool, onProxyForObject object: ParentObject) -> Disposable {
        weak var weakForwardDelegate: AnyObject? = forwardDelegate
        let proxy = self.proxy(for: object)

        assert(proxy.forwardToDelegate() === nil, "This is a feature to warn you that there is already a delegate (or data source) set somewhere previously. The action you are trying to perform will clear that delegate (data source) and that means that some of your features that depend on that delegate (data source) being set will likely stop working.\n" +
            "If you are ok with this, try to set delegate (data source) to `nil` in front of this operation.\n" +
            " This is the source object value: \(object)\n" +
            " This this the original delegate (data source) value: \(proxy.forwardToDelegate()!)\n" +
            "Hint: Maybe delegate was already set in xib or storyboard and now it's being overwritten in code.\n")

        proxy.setForwardToDelegate(forwardDelegate, retainDelegate: retainDelegate)

        return Disposables.create {
            MainScheduler.ensureExecutingOnScheduler()

            let delegate: AnyObject? = weakForwardDelegate

            assert(delegate == nil || proxy.forwardToDelegate() === delegate, "Delegate was changed from time it was first set. Current \(String(describing: proxy.forwardToDelegate())), and it should have been \(proxy)")

            proxy.setForwardToDelegate(nil, retainDelegate: retainDelegate)
        }
    }
}

    #if os(iOS) || os(tvOS)
        import UIKit

        extension ObservableType {
            func subscribeProxyDataSource<DelegateProxy: DelegateProxyType>(ofObject object: DelegateProxy.ParentObject, dataSource: DelegateProxy.Delegate, retainDataSource: Bool, binding: @escaping (DelegateProxy, Event<E>) -> Void)
                -> Disposable
                where DelegateProxy.ParentObject: UIView {
                let proxy = DelegateProxy.proxy(for: object)
                let unregisterDelegate = DelegateProxy.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)
                // this is needed to flush any delayed old state (https://github.com/RxSwiftCommunity/RxDataSources/pull/75)
                object.layoutIfNeeded()

                let subscription = self.asObservable()
                    .observeOn(MainScheduler())
                    .catchError { error in
                        bindingErrorToInterface(error)
                        return Observable.empty()
                    }
                    // source can never end, otherwise it would release the subscriber, and deallocate the data source
                    .concat(Observable.never())
                    .takeUntil(object.rx.deallocated)
                    .subscribe { [weak object] (event: Event<E>) in

                        if let object = object {
                            assert(proxy === DelegateProxy.currentDelegate(for: object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(String(describing: DelegateProxy.currentDelegate(for: object)))")
                        }
                        
                        binding(proxy, event)
                        
                        switch event {
                        case .error(let error):
                            bindingErrorToInterface(error)
                            unregisterDelegate.dispose()
                        case .completed:
                            unregisterDelegate.dispose()
                        default:
                            break
                        }
                    }
                    
                return Disposables.create { [weak object] in
                    subscription.dispose()
                    object?.layoutIfNeeded()
                    unregisterDelegate.dispose()
                }
            }
        }

    #endif

#endif
