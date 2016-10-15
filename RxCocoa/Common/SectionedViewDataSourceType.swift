//
//  SectionedViewDataSourceType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 1/10/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Data source with access to underlying sectioned model.
*/
public protocol SectionedViewDataSourceType {
    /**
     Returns model at index path.
     
     In case data source doesn't contain any sections when this method is being called, `RxCocoaError.ItemsNotYetBound(object: self)` is thrown.

     - parameter indexPath: Model index path 
     - returns: Model at index path.
    */
    func model(_ indexPath: IndexPath) throws -> Any
}

extension SectionedViewDataSourceType {
    /**
     Returns model at index path.

     In case data source doesn't contain any sections when this method is being called, `RxCocoaError.ItemsNotYetBound(object: self)` is thrown.

     - parameter indexPath: Model index path
     - returns: Model at index path.
     */
    @available(*, deprecated, renamed: "model(_:)")
    func modelAtIndexPath(_ indexPath: IndexPath) throws -> Any {
        return try self.model(indexPath)
    }
}
