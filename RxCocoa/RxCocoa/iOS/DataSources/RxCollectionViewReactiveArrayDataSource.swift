//
//  RxCollectionViewReactiveArrayDataSource.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public class RxCollectionViewReactiveArrayDataSource<ElementType> : RxCollectionViewNopDataSource
                                                                  , RxCollectionViewReactiveDataSourceType {
    typealias Element = [ElementType]
    
    typealias CellFactory = (UICollectionView, NSIndexPath, ElementType) -> UICollectionViewCell
    typealias SupplementaryViewFactory = (UICollectionView, String, NSIndexPath, ElementType) -> UICollectionReusableView
    
    var itemModels: [ElementType]? = nil
    
    public func modelAtIndex(index: Int) -> ElementType? {
        return itemModels?[index]
    }
    
    public var cellFactory: CellFactory
    public var supplementaryViewFactory: SupplementaryViewFactory
    
    init(cellFactory: CellFactory) {
        self.cellFactory = cellFactory
        self.supplementaryViewFactory = { (_, _, _, _) in
            rxFatalError("Supplementary view factory not set")
            return rxAbstractMethod()
        }
    }
    
    
    // data source
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellFactory(collectionView, indexPath, itemModels![indexPath.item])
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return supplementaryViewFactory(collectionView, kind, indexPath, itemModels![indexPath.item])
    }
    
    // reactive
    
    public func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .Next(let boxedNext):
            self.itemModels = boxedNext.value
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
        
        collectionView.reloadData()
    }
}