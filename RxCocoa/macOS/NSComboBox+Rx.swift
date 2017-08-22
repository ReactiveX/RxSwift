//
//  NSComboBox+Rx.swift
//  RxCocoa
//
//  Created by Jacob Gorban on 07/17/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif
    
/// Delegate proxy for `NSComboBox`.
///
/// For more information take a look at `DelegateProxyType`.
public class RxComboBoxDelegateProxy
    : DelegateProxy
    , NSComboBoxDelegate
    , DelegateProxyType {

    fileprivate let selectionIndexSubject = PublishSubject<Int>()

    /// Typed parent object.
    public weak private(set) var comboBox: NSComboBox?

    /// Initializes `RxComboBoxDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.comboBox = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }

    // MARK: Delegate methods

    public func comboBoxSelectionDidChange(_ notification: Notification) {
        let comboBox: NSComboBox = castOrFatalError(notification.object)
        let nextValue = comboBox.indexOfSelectedItem
        self.selectionIndexSubject.on(.next(nextValue))
        _forwardToDelegate?.comboBoxSelectionDidChange?(notification)
    }

    // MARK: Delegate proxy methods

    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let control: NSComboBox = castOrFatalError(object)
        return control.createComboBoxRxDelegateProxy()
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let comboBox: NSComboBox = castOrFatalError(object)
        return comboBox.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let comboBox: NSComboBox = castOrFatalError(object)
        comboBox.delegate = castOptionalOrFatalError(delegate)
    }
}

extension NSComboBox {

    /// Factory method that enables subclasses to implement their own `delegate`.
    ///
    /// - returns: Instance of delegate proxy that wraps `delegate`.
    public func createComboBoxRxDelegateProxy() -> RxComboBoxDelegateProxy {
        return RxComboBoxDelegateProxy(parentObject: self)
    }
}

extension Reactive where Base: NSComboBox {

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    /// Can't name the var `delegate` because Reactive\<NSTextField\>, which is an extension on NSComboBox superclass, defines it under the name delegate
    public var delegateProxy: DelegateProxy {
        return RxComboBoxDelegateProxy.proxyForObject(base)
    }

    /// Reactive wrapper for `indexOfSelectedItem` property.
    public var indexOfSelectedItem: ControlProperty<Int> {
        let delegate = RxComboBoxDelegateProxy.proxyForObject(base)

        let source = Observable.deferred { [weak comboBox = self.base] () -> Observable<Int> in
            guard let comboBox = comboBox else {
                return Observable.empty()
            }
            return delegate.selectionIndexSubject.startWith(comboBox.indexOfSelectedItem)
            }.takeUntil(deallocated)

        let observer = UIBindingObserver(UIElement: base) { (control, value: Int) in
            guard value >= 0, value < control.numberOfItems else { return }
            control.selectItem(at: value)
        }

        return ControlProperty(values: source, valueSink: observer.asObserver())
    }

}


#endif
