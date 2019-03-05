//
//  UIApplication+ControlEvent.swift
//  RxCocoa
//
//  Created by SIARHEI LUKYANAU on 05.03.2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import Foundation

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
