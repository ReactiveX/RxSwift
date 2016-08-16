//
//  MessageSentObserver.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif

#if !DISABLE_SWIZZLING

    class DeallocatingObservable
        : ObservableConvertibleType
        , RXMessageSentObserver {
        typealias E = ()

        private let _subject = ReplaySubject<()>.create(bufferSize: 1)

        @objc var targetImplementation: IMP = RX_default_target_implementation()

        var isActive: Bool {
            return targetImplementation != RX_default_target_implementation()
        }

        init() {
        }

        @objc func messageSent(withParameters parameters: [Any]) -> Void {
            _subject.on(.next())
        }

        func asObservable() -> Observable<()> {
            return _subject
        }

        deinit {
            _subject.on(.completed)
        }
    }

    class MessageSentObservable
        : ObservableConvertibleType
        , RXMessageSentObserver {
        typealias E = [AnyObject]

        private let _subject = PublishSubject<[AnyObject]>()

        @objc var targetImplementation: IMP = RX_default_target_implementation()

        var isActive: Bool {
            return targetImplementation != RX_default_target_implementation()
        }

        init() {
        }

        @objc func messageSent(withParameters parameters: [Any]) -> Void {
            _subject.on(.next(parameters as [AnyObject]))
        }

        func asObservable() -> Observable<[AnyObject]> {
            return _subject
        }

        deinit {
            _subject.on(.completed)
        }
    }

#endif
