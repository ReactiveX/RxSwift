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
        static var factory = DelegateProxyFactory { (parentObject: UIScrollView) in
            RxScrollViewDelegateProxy(parentObject: parentObject)
        }
    ...


If need to extend them, chain `extended` after DelegateProxyFactory.init

    class RxScrollViewDelegateProxy: DelegateProxy {
        static var factory = DelegateProxyFactory { (parentObject: UIScrollView) in
                RxScrollViewDelegateProxy(parentObject: parentObject)
            }
            .extended { (parentObject: UITableView) in
                RxTableViewDelegateProxy(parentObject: parentObject)
            }
    ...
 
 
 */
public class DelegateProxyFactory {
    private var _factories: [ObjectIdentifier: ((AnyObject) -> AnyObject)]
    public init<Object: AnyObject>(factory: @escaping (Object) -> AnyObject) {
        _factories = [ObjectIdentifier(Object.self): { factory(castOrFatalError($0)) }]
    }
    
    /**
     Extend DelegateProxyFactory for specific object class and delegate proxy.
     Define object class on closure argument.
    */
    public func extended<Object: AnyObject>(factory: @escaping (Object) -> AnyObject) -> DelegateProxyFactory {
        MainScheduler.ensureExecutingOnScheduler()
        guard _factories[ObjectIdentifier(Object.self)] == nil else {
            rxFatalError("The factory of \(Object.self) is duplicated. DelegateProxy is not allowed of duplicated base object type.")
        }
        _factories[ObjectIdentifier(Object.self)] = { factory(castOrFatalError($0)) }
        return self
    }
    
    /**
     Create DelegateProxy for object.
     DelegateProxyFactory should have a factory of object class (or superclass).
    */
    public func createProxy(for object: AnyObject) -> AnyObject {
        MainScheduler.ensureExecutingOnScheduler()
        var mirror: Mirror? = Mirror(reflecting: object)
        while mirror != nil {
            if let factory = _factories[ObjectIdentifier(mirror!.subjectType)] {
                return factory(object)
            }
            mirror = mirror?.superclassMirror
        }
        rxFatalError("DelegateProxy has no factory of \(object). Call 'DelegateProxy.extend' first.")
    }
}
    
#endif
