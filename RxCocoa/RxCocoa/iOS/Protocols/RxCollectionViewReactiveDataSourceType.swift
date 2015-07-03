//
//  RxCollectionViewReactiveDataSourceType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public protocol RxCollectionViewReactiveDataSourceType : RxCollectionViewDataSourceType {
    typealias Element
    
    func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) -> Void
}