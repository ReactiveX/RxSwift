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
        
        public var viewWillAppear: ControlEvent<Bool> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewWillAppear(_:))).map { args in
                assert(args.count == 1)
                assert(args.first is Bool)
                return args.first as! Bool
            })
        }
        
        public var viewDidAppear: ControlEvent<Bool> {
            return ControlEvent(events: self.sentMessage(#selector(UIViewController.viewDidAppear(_:))).map { args in
                assert(args.count == 1)
                assert(args.first is Bool)
                return args.first as! Bool
            })
        }
        
        public var viewWillDisappear: ControlEvent<Bool> {
            return ControlEvent(events: self.sentMessage(#selector(UIViewController.viewWillDisappear(_:))).map { args in
                assert(args.count == 1)
                assert(args.first is Bool)
                return args.first as! Bool
            })
        }
        
        public var viewDidDisapppear: ControlEvent<Bool> {
            return ControlEvent(events: self.sentMessage(#selector(UIViewController.viewDidDisappear(_:))).map { args in
                assert(args.count == 1)
                assert(args.first is Bool)
                return args.first as! Bool
            })
        }
        
        public var viewWillLayoutSubviews: ControlEvent<Void> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewWillLayoutSubviews)).map { _ in })
        }
        
        public var viewDidLayoutSubviews: ControlEvent<Void> {
            return ControlEvent(events: sentMessage(#selector(UIViewController.viewDidLayoutSubviews)).map { _ in })
        }
    }
#endif
