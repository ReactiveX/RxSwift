//
//  DelegateProxyFactory.swift
//  RxCocoa
//
//  Created by tarunon on 2017/06/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if !os(Linux)
    
#if !RX_NO_MODULE
    import RxSwift
#endif

/**
Define `DelegateProxy.init` for a specific object type.
For example, in RxScrollViewDelegateProxy


    class RxScrollViewDelegateProxy: DelegateProxy {
        static var factory: DelegateProxyFactory {
            return DelegateProxyFactory.sharedFactory(for: RxScrollViewDelegateProxy<UIScrollView>.self)
        }
    ...


If need to extend them, call `DelegateProxySubclass.register()` in extend closure.

    class RxScrollViewDelegateProxy: DelegateProxy {
        static var factory: DelegateProxyFactory {
            return DelegateProxyFactory.sharedFactory(for: RxScrollViewDelegateProxy<UIScrollView>.self) {
                RxTableViewDelegateProxy<UITableView>.register()
            }
        }
    ...
 

 */
public class DelegateProxyFactory {
    private static var _sharedFactories: [ObjectIdentifier: DelegateProxyFactory] = [:]

    /**
     Shared instance of DelegateProxyFactory, if isn't exist shared instance, make DelegateProxyFactory instance for proxy type and extends.
     DelegateProxyFactory have a shared instance per Delegate type.
     - parameter proxyType: DelegateProxy type. Should use concrete DelegateProxy type, not generic.
     - parameter extends: Extend DelegateProxyFactory if needs. See 'DelegateProxyType'.
     - returns: DelegateProxyFactory shared instance.
     */
    public static func sharedFactory<DelegateProxy: DelegateProxyProtocol & DelegateProxyType>(for proxyType: DelegateProxy.Type, extends: (() -> Void)? = nil) -> DelegateProxyFactory {
        MainScheduler.ensureExecutingOnScheduler()
        if let factory = _sharedFactories[ObjectIdentifier(DelegateProxy.Delegate.self)] {
            return factory
        }
        let factory = DelegateProxyFactory(for: proxyType)
        _sharedFactories[ObjectIdentifier(DelegateProxy.Delegate.self)] = factory
        extends?()
        return factory
    }

    private var _factories: [ObjectIdentifier: ((AnyObject) -> AnyObject)]

    private init<DelegateProxy: DelegateProxyProtocol & DelegateProxyType>(for proxyType: DelegateProxy.Type) {
        _factories = [:]
        self.extend(with: proxyType)
    }

    /**
     Extend DelegateProxyFactory for specific object class and delegate proxy.
     Define object class on closure argument.
    */
    internal func extend<DelegateProxy: DelegateProxyProtocol & DelegateProxyType>(with proxyType: DelegateProxy.Type) {
        MainScheduler.ensureExecutingOnScheduler()
        assert((DelegateProxy.self as? DelegateProxy.Delegate) != nil, "DelegateProxy subclass should be as a Delegate")
        guard _factories[ObjectIdentifier(DelegateProxy.ParentObject.self)] == nil else {
            rxFatalError("The factory of \(DelegateProxy.ParentObject.self) is duplicated. DelegateProxy is not allowed of duplicated base object type.")
        }
        _factories[ObjectIdentifier(DelegateProxy.ParentObject.self)] = { proxyType.init(parentObject: castOrFatalError($0)) }
    }
    
    /**
     Create DelegateProxy for object.
     DelegateProxyFactory should have a factory of object class (or superclass).
     Should not call this function directory, use 'DelegateProxy.proxyForObject'
    */
    internal func createProxy(for object: AnyObject) -> AnyObject {
        MainScheduler.ensureExecutingOnScheduler()
        var mirror: Mirror? = Mirror(reflecting: object)
        while mirror != nil {
            if let factory = _factories[ObjectIdentifier(mirror!.subjectType)] {
                return factory(object)
            }
            mirror = mirror?.superclassMirror
        }
        rxFatalError("DelegateProxy has no factory of \(object). Implement DelegateProxy subclass for \(object) first.")
    }
}
    
#endif
