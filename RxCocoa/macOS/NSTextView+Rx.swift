//
//  NSTextView+Rx.swift
//  RxCocoa
//
//  Created by Cee on 8/5/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import Cocoa
import RxSwift

/// Delegate proxy for `NSTextView`.
///
/// For more information take a look at `DelegateProxyType`.
open class RxTextViewDelegateProxy: DelegateProxy<NSTextView, NSTextViewDelegate>, DelegateProxyType, NSTextViewDelegate {

    /// Typed parent object.
    public weak private(set) var textView: NSTextView?

    /// Initializes `RxTextViewDelegateProxy`
    ///
    /// - parameter textView: Parent object for delegate proxy.
    init(textView: NSTextView) {
        self.textView = textView
        super.init(parentObject: textView, delegateProxy: RxTextViewDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxTextViewDelegateProxy(textView: $0) }
    }

    fileprivate let textSubject = PublishSubject<String>()

    // MARK: Delegate methods

    open func textDidChange(_ notification: Notification) {
        let textView: NSTextView = castOrFatalError(notification.object)
        let nextValue = textView.string
        self.textSubject.on(.next(nextValue))
        self.forwardToDelegate?.textDidChange?(notification)
    }

    // MARK: Delegate proxy methods

    /// For more information take a look at `DelegateProxyType`.
    open class func currentDelegate(for object: ParentObject) -> NSTextViewDelegate? {
        object.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func setCurrentDelegate(_ delegate: NSTextViewDelegate?, to object: ParentObject) {
        object.delegate = delegate
    }

}

extension Reactive where Base: NSTextView {

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy<NSTextView, NSTextViewDelegate> {
        RxTextViewDelegateProxy.proxy(for: self.base)
    }

    /// Reactive wrapper for `string` property.
    public var string: ControlProperty<String> {
        let delegate = RxTextViewDelegateProxy.proxy(for: self.base)

        let source = Observable.deferred { [weak textView = self.base] in
            delegate.textSubject.startWith(textView?.string ?? "")
        }.takeUntil(self.deallocated)

        let observer = Binder(self.base) { control, value in
            control.string = value
        }

        return ControlProperty(values: source, valueSink: observer.asObserver())
    }

}

#endif
