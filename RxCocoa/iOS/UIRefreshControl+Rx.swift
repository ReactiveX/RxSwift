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

extension UIRefreshControl {

    /**
    Bindable sink for `beginRefreshing()`, `endRefreshing()` methods.
    */
    public var rx_refreshing: AnyObserver<Bool> {
        return AnyObserver {event in
            MainScheduler.ensureExecutingOnScheduler()

            switch (event) {
            case .Next(let value):
                if value {
                    self.beginRefreshing()
                } else {
                    self.endRefreshing()
                }
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }

}

#endif
