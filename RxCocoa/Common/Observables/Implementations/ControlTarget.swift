//
//  ControlTarget.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(OSX)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

#if os(iOS) || os(tvOS)
    import UIKit

    typealias Control = UIKit.UIControl
    typealias ControlEvents = UIKit.UIControlEvents
#elseif os(OSX)
    import Cocoa

    typealias Control = Cocoa.NSControl
#endif

// This should be only used from `MainScheduler`
class ControlTarget: RxTarget {
    typealias Callback = (Control) -> Void

    let selector: Selector = #selector(ControlTarget.eventHandler(_:))

    weak var control: Control?
#if os(iOS) || os(tvOS)
    let controlEvents: UIControlEvents
#endif
    var callback: Callback?
    #if os(iOS) || os(tvOS)
    init(control: Control, controlEvents: UIControlEvents, callback: @escaping Callback) {
        MainScheduler.ensureExecutingOnScheduler()

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
#elseif os(OSX)
    init(control: Control, callback: @escaping Callback) {
        MainScheduler.ensureExecutingOnScheduler()

        self.control = control
        self.callback = callback

        super.init()

        control.target = self
        control.action = selector

        let method = self.method(for: selector)
        if method == nil {
            rxFatalError("Can't find method")
        }
    }
#endif

    func eventHandler(_ sender: Control!) {
        if let callback = self.callback, let control = self.control {
            callback(control)
        }
    }

    override func dispose() {
        super.dispose()
#if os(iOS) || os(tvOS)
        self.control?.removeTarget(self, action: self.selector, for: self.controlEvents)
#elseif os(OSX)
        self.control?.target = nil
        self.control?.action = nil
#endif
        self.callback = nil
    }
}

#endif
