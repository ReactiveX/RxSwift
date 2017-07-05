//
//  UIPickerView+Rx.swift
//  RxCocoa
//
//  Created by Segii Shulga on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
    
#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit

    extension UIPickerView {

        /// Factory method that enables subclasses to implement their own `delegate`.
        ///
        /// - returns: Instance of delegate proxy that wraps `delegate`.
        public func createRxDelegateProxy() -> RxPickerViewDelegateProxy {
            return RxPickerViewDelegateProxy(parentObject: self)
        }
        
        /**
         Factory method that enables subclasses to implement their own `rx.dataSource`.
         
         - returns: Instance of delegate proxy that wraps `dataSource`.
         */
        public func createRxDataSourceProxy() -> RxPickerViewDataSourceProxy {
            return RxPickerViewDataSourceProxy(parentObject: self)
        }

    }
    
    extension Reactive where Base: UIPickerView {

        /// Reactive wrapper for `delegate`.
        /// For more information take a look at `DelegateProxyType` protocol documentation.
        public var delegate: DelegateProxy {
            return RxPickerViewDelegateProxy.proxyForObject(base)
        }
        
        /// Installs delegate as forwarding delegate on `delegate`.
        /// Delegate won't be retained.
        ///
        /// It enables using normal delegate mechanism with reactive delegate mechanism.
        ///
        /// - parameter delegate: Delegate object.
        /// - returns: Disposable object that can be used to unbind the delegate.
        public func setDelegate(_ delegate: UIPickerViewDelegate)
            -> Disposable {
                return RxPickerViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
        }
        
        public var itemSelected: ControlEvent<(Int, Int)> {
            let source = delegate
                .methodInvoked(#selector(UIPickerViewDelegate.pickerView(_:didSelectRow:inComponent:)))
                .map {
                    return (try castOrThrow(Int.self, $0[1]), try castOrThrow(Int.self, $0[2]))
                }
            return ControlEvent(events: source)
        }
        
        public func items<O: ObservableType,
                          Adapter: RxPickerViewDataSourceType & UIPickerViewDataSource & UIPickerViewDelegate>(adapter: Adapter)
            -> (_ source: O)
            -> Disposable where O.E == Adapter.Element {
                return { source in
                    let delegateSubscription = self.setDelegate(adapter)
                    let dataSourceSubscription = source.subscribeProxyDataSource(ofObject: self.base, dataSource: adapter, retainDataSource: true, binding: { [weak pickerView = self.base] (_: RxPickerViewDataSourceProxy, event) in
                        guard let pickerView = pickerView else { return }
                        adapter.pickerView(pickerView, observedEvent: event)
                    })
                    return Disposables.create(delegateSubscription, dataSourceSubscription)
                }
        }
    }

#endif
