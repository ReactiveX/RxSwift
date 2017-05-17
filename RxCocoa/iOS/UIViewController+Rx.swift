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
        
        public var viewDidLoad: ControlEvent<[Any]> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewDidLoad)))
        }
        
        public var viewWillAppear: ControlEvent<[Any]> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewWillAppear(_:))))
        }
        
        public var viewDidAppear: ControlEvent<[Any]> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewDidAppear(_:))))
        }
        
        public var viewWillDisappear: ControlEvent<[Any]> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewWillDisappear(_:))))
        }
        
        public var viewDidDisapppear: ControlEvent<[Any]> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewDidDisappear(_:))))
        }
        
        public var viewWillLayoutSubviews: ControlEvent<[Any]> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewWillLayoutSubviews)))
        }
        
        public var viewDidLayoutSubviews: ControlEvent<[Any]> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewDidLayoutSubviews)))
        }
    }
#endif
