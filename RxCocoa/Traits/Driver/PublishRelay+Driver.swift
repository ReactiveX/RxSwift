//
//  PublishRelay+Driver.swift
//  RxSwift-iOS
//
//  Created by yuzushioh on 2017/10/09.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

extension PublishRelay {
    /// Converts `PublishReplay` to `Driver`.
    ///
    /// `PublishReplay` can't fail, so no special case needs to be handled.
    ///
    /// - returns: Observable sequence.
    public func asDriver() -> Driver<Element> {
        return self.asDriver { error -> Driver<Element> in
            #if DEBUG
                rxFatalError("Somehow driver received error from a source that shouldn't fail.")
            #else
                return Driver.empty()
            #endif
        }
    }
}
