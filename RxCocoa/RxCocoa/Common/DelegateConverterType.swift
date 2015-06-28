//
//  DelegateConverterType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// If all delegate methods are implemented by just returning dummy values
// some of the behavior is lost. 
//
// E.g. UITableView won't who section headers.
//
// To remedy that, this enables `Rx[UIView]DelegateType`
// to return proxy that answers can it respond to selector.
//
// This kind of brings back optional methods for `Rx[UIView]DelegateType`
public protocol DelegateConverterType {
    var targetDelegate: NSObjectProtocol? {
        get
    }
}