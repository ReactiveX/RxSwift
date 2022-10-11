//
//  RxDelegateProxyCrashFix.swift
//  RxCocoa
//
//  Created by SlashDevSlashGnoll (SlashDevSlashGnoll@users.noreply.github.com) on 9/9/22.
//  Copyright © 2022 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation

// This extension exists solely to get around a crash found on iOS 15.4+ where a `text`
// method invocation is being sent to the RxCollectionViewDelegateProxy which doesn't implement it.
// This is tracked at this bug: https://github.com/ReactiveX/RxSwift/issues/2428 This can be
// removed if/when the actual source of the problem is found
@objc extension RxCollectionViewDelegateProxy {
    var text: String {
        return String()
    }
}

// This extension exists solely to get around a crash found on iOS 15.4+ where a `text`
// method invocation is being sent to the RxTableViewDelegateProxy which doesn't implement it.
// This is tracked at this bug: https://github.com/ReactiveX/RxSwift/issues/2428 This can be
//removed if/when the actual source of the problem is found
@objc extension RxTableViewDelegateProxy {
    var text: String {
        return String()
    }
}
#endif
