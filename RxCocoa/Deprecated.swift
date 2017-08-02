//
//  Deprecated.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/19/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

extension ObservableType {

    /**
     Creates new subscription and sends elements to observer.

     In this form it's equivalent to `subscribe` method, but it communicates intent better, and enables
     writing more consistent binding code.

     - parameter observer: Observer that receives events.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    public func bindTo<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return self.subscribe(observer)
    }

    /**
     Creates new subscription and sends elements to observer.

     In this form it's equivalent to `subscribe` method, but it communicates intent better, and enables
     writing more consistent binding code.

     - parameter observer: Observer that receives events.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    public func bindTo<O: ObserverType>(_ observer: O) -> Disposable where O.E == E? {
        return self.map { $0 }.subscribe(observer)
    }

    /**
     Creates new subscription and sends elements to variable.

     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.

     - parameter variable: Target variable for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    public func bindTo(_ variable: Variable<E>) -> Disposable {
        return subscribe { e in
            switch e {
            case let .next(element):
                variable.value = element
            case let .error(error):
                let error = "Binding error to variable: \(error)"
                #if DEBUG
                    rxFatalError(error)
                #else
                    print(error)
                #endif
            case .completed:
                break
            }
        }
    }

    /**
     Creates new subscription and sends elements to variable.

     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.

     - parameter variable: Target variable for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    public func bindTo(_ variable: Variable<E?>) -> Disposable {
        return self.map { $0 as E? }.bindTo(variable)
    }

    /**
     Subscribes to observable sequence using custom binder function.

     - parameter binder: Function used to bind elements from `self`.
     - returns: Object representing subscription.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    public func bindTo<R>(_ binder: (Self) -> R) -> R {
        return binder(self)
    }

    /**
     Subscribes to observable sequence using custom binder function and final parameter passed to binder function
     after `self` is passed.

     public func bindTo<R1, R2>(binder: Self -> R1 -> R2, curriedArgument: R1) -> R2 {
     return binder(self)(curriedArgument)
     }

     - parameter binder: Function used to bind elements from `self`.
     - parameter curriedArgument: Final argument passed to `binder` to finish binding process.
     - returns: Object representing subscription.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    public func bindTo<R1, R2>(_ binder: (Self) -> (R1) -> R2, curriedArgument: R1) -> R2 {
        return binder(self)(curriedArgument)
    }


    /**
     Subscribes an element handler to an observable sequence.

     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.

     - parameter onNext: Action to invoke for each element in the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    @available(*, deprecated, renamed: "bind(onNext:)")
    public func bindNext(_ onNext: @escaping (E) -> Void) -> Disposable {
        return subscribe(onNext: onNext, onError: { error in
            let error = "Binding error: \(error)"
            #if DEBUG
                rxFatalError(error)
            #else
                print(error)
            #endif
        })
    }
}

#if os(iOS) || os(tvOS)
    import UIKit

    extension NSTextStorage {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxTextStorageDelegateProxy {
            fatalError()
        }
    }

    extension UIScrollView {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxScrollViewDelegateProxy {
            fatalError()
        }
    }

    extension UICollectionView {
        @available(*, unavailable, message: "createRxDataSourceProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDataSourceProxy() -> RxCollectionViewDataSourceProxy {
            fatalError()
        }
    }

    extension UITableView {
        @available(*, unavailable, message: "createRxDataSourceProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDataSourceProxy() -> RxTableViewDataSourceProxy {
            fatalError()
        }
    }

    extension UINavigationBar {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxNavigationControllerDelegateProxy {
            fatalError()
        }
    }

    extension UINavigationController {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxNavigationControllerDelegateProxy {
            fatalError()
        }
    }

    extension UITabBar {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxTabBarDelegateProxy {
            fatalError()
        }
    }

    extension UITabBarController {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxTabBarControllerDelegateProxy {
            fatalError()
        }
    }

    extension UISearchBar {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxSearchBarDelegateProxy {
            fatalError()
        }
    }

#endif

#if os(iOS)
    extension UISearchController {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxSearchControllerDelegateProxy {
            fatalError()
        }
    }

    extension UIPickerView {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxPickerViewDelegateProxy {
            fatalError()
        }

        @available(*, unavailable, message: "createRxDataSourceProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDataSourceProxy() -> RxPickerViewDataSourceProxy {
            fatalError()
        }
    }
    extension UIWebView {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxWebViewDelegateProxy {
            fatalError()
        }
    }
#endif

#if os(macOS)
    import Cocoa

    extension NSTextField {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        public func createRxDelegateProxy() -> RxTextFieldDelegateProxy {
            fatalError()
        }
    }
#endif
