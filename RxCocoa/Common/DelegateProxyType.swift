//
//  DelegateProxyType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !os(Linux)

    import func Foundation.objc_getAssociatedObject
    import func Foundation.objc_setAssociatedObject

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


Since RxCocoa needs to automagically create those Proxys and because views that have delegates can be hierarchical

     UITableView : UIScrollView : UIView

.. and corresponding delegates are also hierarchical

     UITableViewDelegate : UIScrollViewDelegate : NSObject

... this mechanism can be extended by using the following snippet in `registerKnownImplementations` or in some other
     part of your app that executes before using `rx.*` (e.g. appDidFinishLaunching).

    RxScrollViewDelegateProxy.register { RxTableViewDelegateProxy(parentObject: $0) }

*/
public protocol DelegateProxyType: class {
    associatedtype ParentObject: AnyObject
    associatedtype Delegate: AnyObject
    
    /// It is require that enumerate call `register` of the extended DelegateProxy subclasses here.
    static func registerKnownImplementations()

    /// Unique identifier for delegate
    static var identifier: UnsafeRawPointer { get }

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
    static func setCurrentDelegate(_ delegate: Delegate?, to object: ParentObject)

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

// default implementations
extension DelegateProxyType {
    /// Unique identifier for delegate
    public static var identifier: UnsafeRawPointer {
        let delegateIdentifier = ObjectIdentifier(Delegate.self)
        let integerIdentifier = Int(bitPattern: delegateIdentifier)
        return UnsafeRawPointer(bitPattern: integerIdentifier)!
    }
}

extension DelegateProxyType {

    /// Store DelegateProxy subclass to factory.
    /// When make 'Rx*DelegateProxy' subclass, call 'Rx*DelegateProxySubclass.register(for:_)' 1 time, or use it in DelegateProxyFactory
    /// 'Rx*DelegateProxy' can have one subclass implementation per concrete ParentObject type.
    /// Should call it from concrete DelegateProxy type, not generic.
    public static func register<Parent>(make: @escaping (Parent) -> Self) {
        self.factory.extend(make: make)
    }

    /// Creates new proxy for target object.
    /// Should not call this function directory, use 'DelegateProxy.proxy(for:)'
    public static func createProxy(for object: AnyObject) -> Self {
        return castOrFatalError(factory.createProxy(for: object))
    }

    /// Returns existing proxy for object or installs new instance of delegate proxy.
    ///
    /// - parameter object: Target object on which to install delegate proxy.
    /// - returns: Installed instance of delegate proxy.
    ///
    ///
    ///     extension Reactive where Base: UISearchBar {
    ///
    ///         public var delegate: DelegateProxy<UISearchBar, UISearchBarDelegate> {
    ///            return RxSearchBarDelegateProxy.proxy(for: base)
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
            self.setCurrentDelegate(proxy, to: object)
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


// fileprivate extensions
extension DelegateProxyType
{
    fileprivate static var factory: DelegateProxyFactory {
        return DelegateProxyFactory.sharedFactory(for: self)
    }


    fileprivate static func assignedProxy(for object: ParentObject) -> Delegate? {
        let maybeDelegate = objc_getAssociatedObject(object, self.identifier)
        return castOptionalOrFatalError(maybeDelegate.map { $0 as AnyObject })
    }

    fileprivate static func assignProxy(_ proxy: Delegate, toObject object: ParentObject) {
        objc_setAssociatedObject(object, self.identifier, proxy, .OBJC_ASSOCIATION_RETAIN)
    }
}

/// Describes an object that has a delegate.
public protocol HasDelegate: AnyObject {
    /// Delegate type
    associatedtype Delegate: AnyObject

    /// Delegate
    var delegate: Delegate? { get set }
}

extension DelegateProxyType where ParentObject: HasDelegate, Self.Delegate == ParentObject.Delegate {
    public static func currentDelegate(for object: ParentObject) -> Delegate? {
        return object.delegate
    }

    public static func setCurrentDelegate(_ delegate: Delegate?, to object: ParentObject) {
        object.delegate = delegate
    }
}

/// Describes an object that has a data source.
public protocol HasDataSource: AnyObject {
    /// Data source type
    associatedtype DataSource: AnyObject

    /// Data source
    var dataSource: DataSource? { get set }
}

extension DelegateProxyType where ParentObject: HasDataSource, Self.Delegate == ParentObject.DataSource {
    public static func currentDelegate(for object: ParentObject) -> Delegate? {
        return object.dataSource
    }

    public static func setCurrentDelegate(_ delegate: Delegate?, to object: ParentObject) {
        object.dataSource = delegate
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
                        bindingError(error)
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
                            bindingError(error)
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

    /**

     To add delegate proxy subclasses call `DelegateProxySubclass.register()` in `registerKnownImplementations` or in some other
     part of your app that executes before using `rx.*` (e.g. appDidFinishLaunching).

         class RxScrollViewDelegateProxy: DelegateProxy {
             public static func registerKnownImplementations() {
                 self.register { RxTableViewDelegateProxy(parentObject: $0) }
         }
         ...


     */
    private class DelegateProxyFactory {
        private static var _sharedFactories: [UnsafeRawPointer: DelegateProxyFactory] = [:]

        fileprivate static func sharedFactory<DelegateProxy: DelegateProxyType>(for proxyType: DelegateProxy.Type) -> DelegateProxyFactory {
            MainScheduler.ensureExecutingOnScheduler()
            let identifier = DelegateProxy.identifier
            if let factory = _sharedFactories[identifier] {
                return factory
            }
            let factory = DelegateProxyFactory(for: proxyType)
            _sharedFactories[identifier] = factory
            DelegateProxy.registerKnownImplementations()
            return factory
        }

        private var _factories: [ObjectIdentifier: ((AnyObject) -> AnyObject)]
        private var _delegateProxyType: Any.Type
        private var _identifier: UnsafeRawPointer

        private init<DelegateProxy: DelegateProxyType>(for proxyType: DelegateProxy.Type) {
            _factories = [:]
            _delegateProxyType = proxyType
            _identifier = proxyType.identifier
        }

        fileprivate func extend<DelegateProxy: DelegateProxyType, ParentObject>(make: @escaping (ParentObject) -> DelegateProxy)
           {
                MainScheduler.ensureExecutingOnScheduler()
                precondition(_identifier == DelegateProxy.identifier, "Delegate proxy has inconsistent identifier")
                precondition((DelegateProxy.self as? DelegateProxy.Delegate) != nil, "DelegateProxy subclass should be as a Delegate")
                guard _factories[ObjectIdentifier(ParentObject.self)] == nil else {
                    rxFatalError("The factory of \(ParentObject.self) is duplicated. DelegateProxy is not allowed of duplicated base object type.")
                }
                _factories[ObjectIdentifier(ParentObject.self)] = { make(castOrFatalError($0)) }
        }

        fileprivate func createProxy(for object: AnyObject) -> AnyObject {
            MainScheduler.ensureExecutingOnScheduler()
            var maybeMirror: Mirror? = Mirror(reflecting: object)
            while let mirror = maybeMirror {
                if let factory = _factories[ObjectIdentifier(mirror.subjectType)] {
                    return factory(object)
                }
                maybeMirror = mirror.superclassMirror
            }
            rxFatalError("DelegateProxy has no factory of \(object). Implement DelegateProxy subclass for \(object) first.")
        }
    }

#endif
