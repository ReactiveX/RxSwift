//
//  RxTableViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateProxyType.swift`
public class RxTableViewDelegateProxy : RxScrollViewDelegateProxy
                                       , UITableViewDelegate {
    public typealias ItemSelectedObserver = ObserverOf<ItemSelectedEvent<UITableView>>
    public typealias ItemSelectedDisposeKey = Bag<ItemSelectedObserver>.KeyType

    public let tableView: UITableView
    
    var itemSelectedObservers: Bag<ItemSelectedObserver> = Bag()
    
    var tableViewDelegate: UITableViewDelegate?
    
    public override init(view: UIView) {
        self.tableView = view as! UITableView
        
        super.init(view: view)
    }
    
    public func addItemSelectedObserver(observer: ItemSelectedObserver) -> ItemSelectedDisposeKey {
        return itemSelectedObservers.put(observer)
    }
    
    public func removeItemSelectedObserver(key: ItemSelectedDisposeKey) {
        let element = itemSelectedObservers.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
    
    // delegate proxy
    
    override public class func setProxyToView(view: UIView, proxy: AnyObject) {
        let _: UITableViewDelegate = castOrFatalError(proxy)
        super.setProxyToView(view, proxy: proxy)
    }
    
    override public func setDelegate(delegate: AnyObject?) {
        let typedDelegate: UITableViewDelegate? = castOptionalOrFatalError(delegate)
        self.tableViewDelegate = typedDelegate
        
        super.setDelegate(delegate)
    }
    
    // dispose
    
    public override var isDisposable: Bool {
        get {
            return super.isDisposable && self.itemSelectedObservers.count == 0
        }
    }
    
    deinit {
        if !isDisposable {
            handleVoidObserverResult(failure(rxError(RxCocoaError.InvalidOperation, "Something went wrong. Deallocating table view delegate while there are still subscribed observers means that some subscription was left undisposed.")))
        }
    }
}