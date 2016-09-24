//
//  UIRefreshControl+Rx.swift
//  RxCocoa
//
//  Created by Yosuke Ishikawa on 1/31/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: UIRefreshControl {

    /**
    Reactive wrapper for `refreshing` property.
    */
    public var refreshing: ControlProperty<Bool> {
        let base = self.base
        
        let begin = sentMessage(#selector(UIRefreshControl.beginRefreshing)).map { _ in true }
        let end = sentMessage(#selector(UIRefreshControl.endRefreshing)).map { _ in false }
        let change = controlEvent(.valueChanged).map { [weak base] in base?.isRefreshing ?? false }

        let values = Observable
            .of(begin, end, change)
            .merge()
            .startWith(base.isRefreshing)
        
        let valueSink = UIBindingObserver<UIRefreshControl, Bool>(UIElement: self.base)
            { refreshControl, refresh in
                if refresh {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            }
            .asObserver()

        return ControlProperty(values: values, valueSink: valueSink)
    }

}

#endif
