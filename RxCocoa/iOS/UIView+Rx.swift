//
//  UIView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: UIView {
    /// Bindable sink for `hidden` property.
    public var isHidden: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, hidden in
            view.isHidden = hidden
        }
    }

    /// Bindable sink for `alpha` property.
    public var alpha: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: self.base) { view, alpha in
            view.alpha = alpha
        }
    }
    
    static func rx_animation(duration: NSTimeInterval, animations: () -> Void) -> Observable<Bool> {
        return Observable.create { observer in
            UIView.animateWithDuration(duration, animations: animations) {
                observer.on(.Next($0))
                observer.on(.Completed)
            }
            return AnonymousDisposable {}
        }
        .observeOn(MainScheduler.instance)
    }
}
    
extension ObservableType {
    /**
     Chaining view animations from Observable.
     */
    func animate(duration: NSTimeInterval, animations: () -> Void) -> Observable<E> {
        return self.flatMap { (element: E) -> Observable<E> in
            return UIView.rx_animation(duration, animations: animations).map { _ in return element }
        }
    }
}

#endif
