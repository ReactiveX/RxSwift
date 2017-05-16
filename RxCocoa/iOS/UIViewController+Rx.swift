//
//  UIViewController+Rx.swift
//  RxCocoa
//
//  Created by Kyle Fuller on 27/05/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
  import UIKit

#if !RX_NO_MODULE
  import RxSwift
#endif

    extension Reactive where Base: UIViewController {

        /// Bindable sink for `title`.
        public var title: UIBindingObserver<Base, String> {
            return UIBindingObserver(UIElement: self.base) { viewController, title in
                viewController.title = title
            }
        }
    
    }
#endif
