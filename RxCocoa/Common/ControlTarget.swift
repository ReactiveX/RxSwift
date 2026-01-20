//
//  ControlTarget.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS) || os(macOS)

import RxSwift

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit

typealias Control = UIKit.UIControl
#elseif os(macOS)
import Cocoa

typealias Control = Cocoa.NSControl
#endif

// This should be only used from `MainScheduler`
final class ControlTarget: RxTarget {
    typealias Callback = (Control) -> Void

    let selector: Selector = #selector(ControlTarget.eventHandler(_:))

    weak var control: Control?
    #if os(iOS) || os(tvOS) || os(visionOS)
    let controlEvents: UIControl.Event
    #endif
    var callback: Callback?
    #if os(iOS) || os(tvOS) || os(visionOS)
    init(control: Control, controlEvents: UIControl.Event, callback: @escaping Callback) {
        MainScheduler.ensureRunningOnMainThread()

        self.control = control
        self.controlEvents = controlEvents
        self.callback = callback

        super.init()

        control.addTarget(self, action: selector, for: controlEvents)

        let method = method(for: selector)
        if method == nil {
            rxFatalError("Can't find method")
        }
    }

    #elseif os(macOS)
    init(control: Control, callback: @escaping Callback) {
        MainScheduler.ensureRunningOnMainThread()

        self.control = control
        self.callback = callback

        super.init()

        control.target = self
        control.action = selector

        let method = method(for: selector)
        if method == nil {
            rxFatalError("Can't find method")
        }
    }
    #endif

    @objc func eventHandler(_: Control!) {
        if let callback, let control {
            callback(control)
        }
    }

    override func dispose() {
        super.dispose()
        #if os(iOS) || os(tvOS) || os(visionOS)
        control?.removeTarget(self, action: selector, for: controlEvents)
        #elseif os(macOS)
        control?.target = nil
        control?.action = nil
        #endif
        callback = nil
    }
}

#endif
