//
//  RxTextFieldDelegateProxy.swift
//  RxCocoa
//
//  Created by Takeshi Ihara on 24/3/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

/// For more information take a look at `DelegateProxyType`.
public class RxTextFieldDelegateProxy
    : DelegateProxy
    , UITextFieldDelegate
    , DelegateProxyType {

    fileprivate var _shouldClearPublishSubject: PublishSubject<()>?
    fileprivate var _shouldReturnPublishSubject: PublishSubject<()>?

    /// Typed parent object.
    public weak fileprivate(set) var textField: UITextField?

    /// Optimized version used for observing content offset changes.
    internal var shouldClearPublishSubject: PublishSubject<()> {
        if let subject = _shouldClearPublishSubject {
            return subject
        }

        let subject = PublishSubject<()>()
        _shouldClearPublishSubject = subject

        return subject
    }

    /// Optimized version used for observing content offset changes.
    internal var shouldReturnPublishSubject: PublishSubject<()> {
        if let subject = _shouldReturnPublishSubject {
            return subject
        }

        let subject = PublishSubject<()>()
        _shouldReturnPublishSubject = subject

        return subject
    }

    /// Initializes `RxTextFieldViewDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.textField = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }

    // MARK: delegate methods

    /// For more information take a look at `DelegateProxyType`.
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        _shouldClearPublishSubject?.onNext()
        return self._forwardToDelegate?.textFieldShouldClear?(textField) ?? true
    }

    /// For more information take a look at `DelegateProxyType`.
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _shouldReturnPublishSubject?.onNext()
        return self._forwardToDelegate?.textFieldShouldReturn?(textField) ?? true
    }

    // MARK: delegate proxy

    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let textField: UITextField = castOrFatalError(object)
        return textField.createRxDelegateProxy()
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let textField: UITextField = castOrFatalError(object)
        textField.delegate = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let textField: UITextField = castOrFatalError(object)
        return textField.delegate
    }

    deinit {
        if let subject = _shouldClearPublishSubject {
            subject.on(.completed)
        }
        if let subject = _shouldReturnPublishSubject {
            subject.on(.completed)
        }
    }
}

#endif
