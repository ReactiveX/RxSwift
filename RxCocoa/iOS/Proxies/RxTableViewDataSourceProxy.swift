//
//  RxTableViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

class TableViewDataSourceNotSet
    : NSObject
    , UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
}

/// For more information take a look at `DelegateProxyType`.
public class RxTableViewDataSourceProxy
    : DelegateProxy
    , UITableViewDataSource
    , DelegateProxyType {

    /// Typed parent object.
    public weak fileprivate(set) var tableView: UITableView?

    // issue https://github.com/ReactiveX/RxSwift/issues/907
    private var _numberOfObservers = 0
    private var _commitForRowAtSequenceSentMessage: CachedCommitForRowAt? = nil
    private var _commitForRowAtSequenceMethodInvoked: CachedCommitForRowAt? = nil

    fileprivate class Counter {
        var hasObservers: Bool = false
    }
    
    fileprivate class CachedCommitForRowAt {
        let sequence: Observable<[Any]>
        let counter: Counter

        var hasObservers: Bool {
            return counter.hasObservers
        }

        init(sequence: Observable<[Any]>, counter: Counter) {
            self.sequence = sequence
            self.counter = counter
        }
        
        static func createFor(commitForRowAt: Observable<[Any]>, proxy: RxTableViewDataSourceProxy) -> CachedCommitForRowAt {
            let counter = Counter()

            let commitForRowAtSequence = commitForRowAt.do(onSubscribe: { [weak proxy] in
                        counter.hasObservers = true
                        proxy?.refreshTableViewDataSource()
                    }, onDispose: { [weak proxy] in
                        counter.hasObservers = false
                        proxy?.refreshTableViewDataSource()
                    })
                .subscribeOn(MainScheduler())
                .share()

            return CachedCommitForRowAt(sequence: commitForRowAtSequence, counter: counter)
        }
    }

    fileprivate weak var _requiredMethodsDataSource: UITableViewDataSource? = tableViewDataSourceNotSet

    /// Initializes `RxTableViewDataSourceProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.tableView = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }

    // MARK: delegate

    /// Required delegate method implementation.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, numberOfRowsInSection: section)
    }

    /// Required delegate method implementation.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: proxy

    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let tableView: UITableView = castOrFatalError(object)
        return tableView.createRxDataSourceProxy()
    }

    /// For more information take a look at `DelegateProxyType`.
    public override class func delegateAssociatedObjectTag() -> UnsafeRawPointer {
        return _pointer(&dataSourceAssociatedTag)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tableView: UITableView = castOrFatalError(object)
        tableView.dataSource = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tableView: UITableView = castOrFatalError(object)
        return tableView.dataSource
    }

    /// For more information take a look at `DelegateProxyType`.
    public override func setForwardToDelegate(_ forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: UITableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
        refreshTableViewDataSource()
    }

    override open func methodInvoked(_ selector: Selector) -> Observable<[Any]> {
        MainScheduler.ensureExecutingOnScheduler()

        // This is special behavior for commit:forRowAt:
        // If proxy data source responds to this selector then table view will show
        // swipe to delete option even when nobody is observing.
        // https://github.com/ReactiveX/RxSwift/issues/907
        if selector == #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)) {
            guard let commitForRowAtSequenceMethodInvoked = _commitForRowAtSequenceMethodInvoked else {
                let commitForRowAtSequenceMethodInvoked = CachedCommitForRowAt.createFor(commitForRowAt: super.methodInvoked(selector), proxy: self)
                _commitForRowAtSequenceMethodInvoked = commitForRowAtSequenceMethodInvoked
                return commitForRowAtSequenceMethodInvoked.sequence
            }

            return commitForRowAtSequenceMethodInvoked.sequence
        }

        return super.methodInvoked(selector)
    }

    override open func sentMessage(_ selector: Selector) -> Observable<[Any]> {
        MainScheduler.ensureExecutingOnScheduler()

        // This is special behavior for commit:forRowAt:
        // If proxy data source responds to this selector then table view will show
        // swipe to delete option even when nobody is observing.
        // https://github.com/ReactiveX/RxSwift/issues/907
        if selector == #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)) {
            guard let commitForRowAtSequenceSentMessage = _commitForRowAtSequenceSentMessage else {
                let commitForRowAtSequenceSentMessage = CachedCommitForRowAt.createFor(commitForRowAt: super.sentMessage(selector), proxy: self)
                _commitForRowAtSequenceSentMessage = commitForRowAtSequenceSentMessage
                return commitForRowAtSequenceSentMessage.sequence
            }

            return commitForRowAtSequenceSentMessage.sequence
        }

        return super.sentMessage(selector)
    }

    // https://github.com/ReactiveX/RxSwift/issues/907
    private func refreshTableViewDataSource() {
        if self.tableView?.dataSource === self {
            self.tableView?.dataSource = nil
            if _requiredMethodsDataSource != nil && _requiredMethodsDataSource !== tableViewDataSourceNotSet {
                self.tableView?.dataSource = self
            }
        }
    }

    override open func responds(to aSelector: Selector!) -> Bool {
        // https://github.com/ReactiveX/RxSwift/issues/907
        let commitForRowAtSelector = #selector(UITableViewDataSource.tableView(_:commit:forRowAt:))
        if aSelector == commitForRowAtSelector {
            // without `as? UITableViewDataSource` `responds(to:)` fails, 🍻 compiler team
            let forwardDelegateResponds = (self.forwardToDelegate() as? UITableViewDataSource)?.responds(to: commitForRowAtSelector)
            return (_commitForRowAtSequenceSentMessage?.hasObservers ?? false)
                || (_commitForRowAtSequenceMethodInvoked?.hasObservers ?? false)
                || (forwardDelegateResponds ?? false)
        }

        return super.responds(to: aSelector)
    }
}

#endif
