//
//  DeallocatingObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 11/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif

#if !DISABLE_SWIZZLING

    class DeallocatingObserver
        : ObservableConvertibleType
        , RXDeallocatingObserver {
        typealias E = ()

        private let _subject = ReplaySubject<()>.create(bufferSize: 1)

        init() {
        }

        @objc func deallocating() {
            _subject.on(.Next(()))
        }

        @objc func methodForSelectorDoesntExist() {
            _subject.on(.Error(RxCocoaError.ObjectDoesntRespondToMessage))
        }

        @objc func errorDuringSwizzling() {
            _subject.on(.Error(RxCocoaError.ErrorDuringSwizzling))
        }

        func asObservable() -> Observable<()> {
            return _subject
        }

        deinit {
            _subject.on(.Completed)
        }
    }

#endif
