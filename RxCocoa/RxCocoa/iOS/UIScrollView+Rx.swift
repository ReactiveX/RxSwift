//
//  UIScrollView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UIScrollView {
    public func rx_createDelegateBridge() -> RxScrollViewDelegateBridge {
        return RxScrollViewDelegateBridge(view: self)
    }
    
    
    public var rx_contentOffset: Observable<CGPoint> {
        return createObservableUsingDelegateBridge(self, { (b: RxScrollViewDelegateBridge, o) in
            return b.addContentOffsetObserver(o)
        }, { (b, d) -> () in
            b.removeContentOffsetObserver(d)
        })
    }
    
    // delegate
    
    // For more detailed explanations, take a look at `DelegateBridgeType.swift`
    // Retains delegate
    public func rx_setDelegate(delegate: RxScrollViewDelegateType) -> Disposable {
        let result: BridgeDisposablePair<RxScrollViewDelegateBridge> = installDelegateOnBridge(self, delegate)
        
        return result.disposable
    }

    // For more detailed explanations, take a look at `DelegateBridgeType.swift`
    public func rx_setDelegate(delegate: UIScrollViewDelegate, retainDelegate: Bool)
        -> Disposable {
            let converter = RxScrollViewDelegateConverter(delegate: delegate, retainDelegate: retainDelegate)
            let result: BridgeDisposablePair<RxScrollViewDelegateBridge> = installDelegateOnBridge(self, converter)
            
            return result.disposable
    }
}