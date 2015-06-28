//
//  UIItemEvents.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit

public struct ItemSelectedEvent<View> {
    public let view: View
    public let indexPath: NSIndexPath
    
    init(view: View, indexPath: NSIndexPath) {
        self.view = view
        self.indexPath = indexPath
    }
}

public struct InsertItemEvent<View> {
    public let view: View
    public let indexPath: NSIndexPath
    
    init(view: View, indexPath: NSIndexPath) {
        self.view = view
        self.indexPath = indexPath
    }
}

public struct DeleteItemEvent<View> {
    public let view: View
    public let indexPath: NSIndexPath
    
    init(view: View, indexPath: NSIndexPath) {
        self.view = view
        self.indexPath = indexPath
    }
}

public struct MoveItemEvent<View> {
    public let view: View
    public let sourceIndexPath: NSIndexPath
    public let destinationIndexPath: NSIndexPath
    
    init(view: View, sourceIndexPath: NSIndexPath, destinationIndexPath: NSIndexPath) {
        self.view = view
        self.sourceIndexPath = sourceIndexPath
        self.destinationIndexPath = destinationIndexPath
    }
}