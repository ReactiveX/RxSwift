//
//  UIApplication+Rx.swift
//  RxCocoa
//
//  Created by Mads Bøgeskov on 18/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

    import UIKit
    import RxSwift

    extension Reactive where Base: UIApplication {
        
        /// Bindable sink for `networkActivityIndicatorVisible`.
        public var isNetworkActivityIndicatorVisible: Binder<Bool> {
            return Binder(self.base) { application, active in
                application.isNetworkActivityIndicatorVisible = active
            }
        }
    }

    extension Reactive where Base: UIApplication {
        
        public static var willResignActive: ControlEvent<()> {
            let source = NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification).map { _ in return () }
            
            return ControlEvent(events: source)
        }
        
        public static var didEnterBackground: ControlEvent<()> {
            let source = NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).map { _ in return () }
            
            return ControlEvent(events: source)
        }
        
        public static var willEnterForeground: ControlEvent<()> {
            let source = NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).map { _ in return () }
            
            return ControlEvent(events: source)
        }
        
        public static var didBecomeActive: ControlEvent<()> {
            let source = NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).map { _ in return () }
            
            return ControlEvent(events: source)
        }
        
        public static var willTerminate: ControlEvent<()> {
            let source = NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification).map { _ in return () }
            
            return ControlEvent(events: source)
        }
    }
#endif

