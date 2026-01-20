//
//  UIGestureRecognizer+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 10/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

// This should be only used from `MainScheduler`
final class GestureTarget<Recognizer: UIGestureRecognizer>: RxTarget {
    typealias Callback = (Recognizer) -> Void

    let selector = #selector(GestureTarget.eventHandler(_:))

    weak var gestureRecognizer: Recognizer?
    var callback: Callback?

    init(_ gestureRecognizer: Recognizer, callback: @escaping Callback) {
        self.gestureRecognizer = gestureRecognizer
        self.callback = callback

        super.init()

        gestureRecognizer.addTarget(self, action: selector)

        let method = method(for: selector)
        if method == nil {
            fatalError("Can't find method")
        }
    }

    @objc func eventHandler(_: UIGestureRecognizer) {
        if let callback, let gestureRecognizer {
            callback(gestureRecognizer)
        }
    }

    override func dispose() {
        super.dispose()

        gestureRecognizer?.removeTarget(self, action: selector)
        callback = nil
    }
}

public extension Reactive where Base: UIGestureRecognizer {
    /// Reactive wrapper for gesture recognizer events.
    var event: ControlEvent<Base> {
        let source: Observable<Base> = Observable.create { [weak control = self.base] observer in
            MainScheduler.ensureRunningOnMainThread()

            guard let control else {
                observer.on(.completed)
                return Disposables.create()
            }

            let observer = GestureTarget(control) { control in
                observer.on(.next(control))
            }

            return observer
        }.take(until: deallocated)

        return ControlEvent(events: source)
    }
}

#endif
