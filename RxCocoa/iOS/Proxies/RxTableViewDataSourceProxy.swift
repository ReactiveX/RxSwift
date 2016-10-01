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

/**
     For more information take a look at `DelegateProxyType`.
 */
public class RxTableViewDataSourceProxy
    : DelegateProxy
    , UITableViewDataSource
    , DelegateProxyType {

    /**
     Typed parent object.
     */
    public weak fileprivate(set) var tableView: UITableView?

    // issue https://github.com/ReactiveX/RxSwift/issues/907
    private var _commitForRowAtHasObservers = false
    private var _commitForRowAtSequence: Observable<[AnyObject]>? = nil
    
    fileprivate weak var _requiredMethodsDataSource: UITableViewDataSource? = tableViewDataSourceNotSet

    /**
     Initializes `RxTableViewDataSourceProxy`

     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.tableView = (parentObject as! UITableView)
        super.init(parentObject: parentObject)
    }

    // MARK: delegate

    /**
    Required delegate method implementation.
    */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, numberOfRowsInSection: section)
    }

    /**
    Required delegate method implementation.
    */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: proxy

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let tableView = (object as! UITableView)

        return castOrFatalError(tableView.createRxDataSourceProxy())
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override class func delegateAssociatedObjectTag() -> UnsafeRawPointer {
        return _pointer(&dataSourceAssociatedTag)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tableView: UITableView = castOrFatalError(object)
        tableView.dataSource = castOptionalOrFatalError(delegate)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tableView: UITableView = castOrFatalError(object)
        return tableView.dataSource
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override func setForwardToDelegate(_ forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: UITableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

    override open func observe(_ selector: Selector) -> Observable<[AnyObject]> {
        MainScheduler.ensureExecutingOnScheduler()

        // This is special behavior for commit:forRowAt:
        // If proxy data source responds to this selector then table view will show
        // swipe to delete option even when nobody is observing.
        // https://github.com/ReactiveX/RxSwift/issues/907
        if selector == #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)) {
            guard let commitForRowAtSequence = _commitForRowAtSequence else {
                let commitForRowAtSequence = super.observe(selector)
                    .do(onSubscribe: { [weak self] in
                            self?._commitForRowAtHasObservers = true
                            self?.refreshTableViewDataSource()
                        }, onDispose: { [weak self] in
                            self?._commitForRowAtHasObservers = false
                            self?.refreshTableViewDataSource()
                        })
                    .subscribeOn(MainScheduler())
                    .share()

                _commitForRowAtSequence = commitForRowAtSequence
                
                return commitForRowAtSequence
            }

            return commitForRowAtSequence
        }

        return super.observe(selector)
    }

    // https://github.com/ReactiveX/RxSwift/issues/907
    private func refreshTableViewDataSource() {
        if self.tableView?.dataSource === self {
            self.tableView?.dataSource = nil
            self.tableView?.dataSource = self
        }
    }

    override open func responds(to aSelector: Selector!) -> Bool {
        // https://github.com/ReactiveX/RxSwift/issues/907
        if aSelector == #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)) {
            return _commitForRowAtHasObservers
        }

        return super.responds(to: aSelector)
    }
}

#endif
