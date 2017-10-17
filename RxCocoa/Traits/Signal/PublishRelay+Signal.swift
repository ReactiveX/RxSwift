//
//  PublishRelay+Signal.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 12/28/15.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

extension PublishRelay {
    /// Converts `PublishRelay` to `Signal`.
    ///
    /// - returns: Observable sequence.
    public func asSignal() -> Signal<Element> {
        let source = self.asObservable()
            .observeOn(SignalSharingStrategy.scheduler)
        return SharedSequence(source)
    }
}
