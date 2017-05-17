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
        
        public var viewDidLoad: ControlEvent<Void> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewDidLoad)).map { _ in })
        }
        
        public var viewWillAppear: ControlEvent<Void> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewWillAppear(_:))).map { _ in })
        }
        
        public var viewDidAppear: ControlEvent<Void> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewDidAppear(_:))).map { _ in })
        }
        
        public var viewWillDisappear: ControlEvent<Void> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewWillDisappear(_:))).map { _ in })
        }
        
        public var viewDidDisapppear: ControlEvent<Void> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewDidDisappear(_:))).map { _ in })
        }
        
        public var viewWillLayoutSubviews: ControlEvent<Void> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewWillLayoutSubviews)).map { _ in })
        }
        
        public var viewDidLayoutSubviews: ControlEvent<Void> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewDidLayoutSubviews)).map { _ in })
        }
    }
#endif
