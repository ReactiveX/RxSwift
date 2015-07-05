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

let tableViewDelegateNotSet = TableViewDelegateNotSet()

class TableViewDelegateNotSet : NSObject
                              , UITableViewDelegate {
    
}

// Please take a look at `DelegateProxyType.swift`
class RxTableViewDelegateProxy : RxScrollViewDelegateProxy
                               , UITableViewDelegate {
    typealias ItemSelectedObserver = ObserverOf<NSIndexPath>
    typealias ItemSelectedDisposeKey = Bag<ItemSelectedObserver>.KeyType

    unowned let tableView: UITableView
    
    var itemSelectedObservers: Bag<ItemSelectedObserver> = Bag()
    
    required init(parentObject: AnyObject) {
        self.tableView = parentObject as! UITableView
        
        super.init(parentObject: parentObject)
    }
    
    func addItemSelectedObserver(observer: ItemSelectedObserver) -> ItemSelectedDisposeKey {
        return itemSelectedObservers.put(observer)
    }
    
    func removeItemSelectedObserver(key: ItemSelectedDisposeKey) {
        let element = itemSelectedObservers.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
}