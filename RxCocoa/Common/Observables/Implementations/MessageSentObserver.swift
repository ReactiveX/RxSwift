//
//  MessageSentObserver.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif

#if !DISABLE_SWIZZLING

    class MessageSentObservable
        : ObservableConvertibleType
        , RXMessageSentObserver {
        typealias E = [AnyObject]

        private let _observable: Observable<[AnyObject]>
        private let _observer: AnyObserver<[AnyObject]>

        init(observable: Observable<[AnyObject]>, observer: AnyObserver<[AnyObject]>) {
            _observable = observable
            _observer = observer
        }

        @objc func messageSentWithParameters(parameters: [AnyObject]) -> Void {
            _observer.on(.Next(parameters))
        }

        @objc func methodForSelectorDoesntExist() {
            _observer.on(.Error(RxCocoaError.ObjectDoesntRespondToMessage))
        }

        @objc func errorDuringSwizzling() {
            _observer.on(.Error(RxCocoaError.ErrorDuringSwizzling))
        }

        func asObservable() -> Observable<[AnyObject]> {
            return _observable
        }

        deinit {
            _observer.on(.Completed)
        }
    }

    extension MessageSentObservable {
        static func createObserver(replay: Bool) -> MessageSentObservable {
            if replay {
                let replaySubject = ReplaySubject<[AnyObject]>.create(bufferSize: 1)
                return MessageSentObservable(observable: replaySubject.asObservable(), observer: AnyObserver(replaySubject.asObserver()))
            }
            else {
                let publishSubject = PublishSubject<[AnyObject]>()
                return MessageSentObservable(observable: publishSubject.asObservable(), observer: AnyObserver(publishSubject.asObserver()))
            }
        }
    }

#endif
