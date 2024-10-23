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
@MainActor
final class ControlTarget: RxTarget, @unchecked Sendable {
    typealias Callback = @Sendable @MainActor (Control) -> Void

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

        let method = self.method(for: selector)
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
        control.action = self.selector

        let method = self.method(for: self.selector)
        if method == nil {
            rxFatalError("Can't find method")
        }
    }
#endif

    @objc func eventHandler(_ sender: Control!) {
        if let callback = self.callback, let control = self.control {
            callback(control)
        }
    }
    
    @Sendable
    override func dispose() {
        super.dispose()
#if os(iOS) || os(tvOS) || os(visionOS)
        MainScheduler.assumeMainActor(execute: {        
            self.control?.removeTarget(self, action: self.selector, for: self.controlEvents)
        })
#elseif os(macOS)
        MainScheduler.assumeMainActor(execute: {
            self.control?.target = nil
            self.control?.action = nil
        })
#endif
        MainScheduler.assumeMainActor(execute: {
            self.callback = nil
        })
    }
}

#endif
