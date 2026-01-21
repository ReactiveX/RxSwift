//
//  UIApplication+Rx.swift
//  RxCocoa
//
//  Created by Mads Bøgeskov on 18/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(visionOS)

import RxSwift
import UIKit
#endif

#if os(iOS)
public extension Reactive where Base: UIApplication {
    /// Bindable sink for `isNetworkActivityIndicatorVisible`.
    var isNetworkActivityIndicatorVisible: Binder<Bool> {
        Binder(base) { application, active in
            application.isNetworkActivityIndicatorVisible = active
        }
    }
}
#endif

#if os(iOS) || os(visionOS)
public extension Reactive where Base: UIApplication {
    /// Reactive wrapper for `UIApplication.didEnterBackgroundNotification`
    static var didEnterBackground: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.willEnterForegroundNotification`
    static var willEnterForeground: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.didFinishLaunchingNotification`
    static var didFinishLaunching: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.didFinishLaunchingNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.didBecomeActiveNotification`
    static var didBecomeActive: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.willResignActiveNotification`
    static var willResignActive: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.didReceiveMemoryWarningNotification`
    static var didReceiveMemoryWarning: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.didReceiveMemoryWarningNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.willTerminateNotification`
    static var willTerminate: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.significantTimeChangeNotification`
    static var significantTimeChange: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.significantTimeChangeNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.backgroundRefreshStatusDidChangeNotification`
    static var backgroundRefreshStatusDidChange: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.backgroundRefreshStatusDidChangeNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.protectedDataWillBecomeUnavailableNotification`
    static var protectedDataWillBecomeUnavailable: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.protectedDataWillBecomeUnavailableNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.protectedDataDidBecomeAvailableNotification`
    static var protectedDataDidBecomeAvailable: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.protectedDataDidBecomeAvailableNotification).map { _ in }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIApplication.userDidTakeScreenshotNotification`
    static var userDidTakeScreenshot: ControlEvent<Void> {
        let source = NotificationCenter.default.rx.notification(UIApplication.userDidTakeScreenshotNotification).map { _ in }

        return ControlEvent(events: source)
    }
}
#endif
