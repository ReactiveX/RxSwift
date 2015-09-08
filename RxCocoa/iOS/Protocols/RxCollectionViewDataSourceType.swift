//
//  RxCollectionViewDataSourceType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

/**
Reactive data source for collection view.
*/
public protocol RxCollectionViewDataSourceType /*: UICollectionViewDataSource*/ {
    typealias Element
    
    func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) -> Void
}