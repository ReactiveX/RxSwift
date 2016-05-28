//
//  UIViewController+Rx.swift
//  Rx
//
//  Created by Kyle Fuller on 27/05/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS)
  import UIKit

#if !RX_NO_MODULE
  import RxSwift
#endif

  extension UIViewController {

    /**
     Bindable sink for `title`.
     */
    public var rx_title: AnyObserver<String> {
      return UIBindingObserver(UIElement: self) { viewController, title in
        viewController.title = title
      }.asObserver()
    }
  }
#endif