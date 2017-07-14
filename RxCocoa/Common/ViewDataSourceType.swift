//
//  ViewDataSourceType.swift
//  RxCocoa
//
//  Created by Sergey Shulga on 14/07/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

/// Data source with access to underlying model.
public protocol ViewDataSourceType {
    /// Returns model at index.
    ///
    /// In case data source doesn't contain any items when this method is being called, `RxCocoaError.ItemsNotYetBound(object: self)` is thrown.
    
    /// - parameter index: Model index
    /// - returns: Model at index.
    func model(at index: Int) throws -> Any
}
