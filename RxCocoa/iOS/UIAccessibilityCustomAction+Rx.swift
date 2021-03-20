//
//  UIAccessibilityCustomAction+Rx.swift
//  RxCocoa
//
//  Created by Evan Anger on 3/19/21.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift

extension UIAccessibilityCustomAction {
    public convenience init(name: String) {
        self.init(
            name: name,
            target: nil,
            selector: #selector(AccessibilityCustomActionTarget.noOp(_:))
        )
    }
}

private var rx_custom_action_key: UInt8 = 0
extension Reactive where Base: UIAccessibilityCustomAction {
    public var action: ControlEvent<()> {
        let source = lazyInstanceObservable(&rx_custom_action_key) { () -> Observable<()> in
            Observable.create { [weak control = self.base] observer in
                guard let control = control else {
                    observer.on(.completed)
                    return Disposables.create()
                }
                let target = AccessibilityCustomActionTarget(customAction: control) {
                    observer.on(.next(()))
                }
                return target
            }
            .take(until: self.deallocated)
            .share()
        }
        return ControlEvent(events: source)
    }
}

@objc
final class AccessibilityCustomActionTarget: RxTarget {
    typealias Callback = () -> Void
    
    weak var customAction: UIAccessibilityCustomAction?
    var callback: Callback!
    
    init(customAction: UIAccessibilityCustomAction, callback: @escaping () -> Void) {
        self.customAction = customAction
        self.callback = callback
        super.init()
        customAction.target = self
        customAction.selector = #selector(AccessibilityCustomActionTarget.action(_:))
    }
    
    override func dispose() {
        super.dispose()
#if DEBUG
        MainScheduler.ensureRunningOnMainThread()
#endif
        customAction?.target = nil
        customAction?.selector = #selector(AccessibilityCustomActionTarget.noOp(_:))
        
        callback = nil
    }
    
    @objc func action(_ sender: AnyObject) {
        callback()
    }
    
    @objc func noOp(_ sender: AnyObject) {}
}

#endif
