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
        static var delegateProxyFactory = DelegateProxyFactory { (parentObject: UIScrollView) in
            RxScrollViewDelegateProxy(parentObject: parentObject)
        }
    ...


If need to extend them, chain `extended` after DelegateProxyFactory.init

    class RxScrollViewDelegateProxy: DelegateProxy {
        static var delegateProxyFactory = DelegateProxyFactory { (parentObject: UIScrollView) in
                RxScrollViewDelegateProxy(parentObject: parentObject)
            }
            .extended { (parentObject: UITableView) in
                RxTableViewDelegateProxy(parentObject: parentObject)
            }
    ...
 
 
 */
public class DelegateProxyFactory {
    var factories: [ObjectIdentifier: ((AnyObject) -> AnyObject)]
    public init<Object: AnyObject>(factory: @escaping (Object) -> AnyObject) {
        factories = [ObjectIdentifier(Object.self): { factory(castOrFatalError($0)) }]
    }
    
    public func extended<Object: AnyObject>(factory: @escaping (Object) -> AnyObject) -> DelegateProxyFactory {
        guard factories[ObjectIdentifier(Object.self)] == nil else {
            rxFatalError("The factory of \(Object.self) is duplicated. DelegateProxy is not allowed of duplicated base object type.")
        }
        factories[ObjectIdentifier(Object.self)] = { factory(castOrFatalError($0)) }
        return self
    }
    
    func createProxy(for object: AnyObject) -> AnyObject {
        var mirror: Mirror? = Mirror(reflecting: object)
        while mirror != nil {
            if let factory = factories[ObjectIdentifier(mirror!.subjectType)] {
                return factory(object)
            }
            mirror = mirror?.superclassMirror
        }
        rxFatalError("DelegateProxy has no factory of \(object). Call 'DelegateProxy.extend' first.")
    }
}
    
#endif
