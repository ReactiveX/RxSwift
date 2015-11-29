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

        private let _subject = PublishSubject<[AnyObject]>()

        init() {
            
        }

        @objc func messageSentWithParameters(parameters: [AnyObject]) -> Void {
            _subject.on(.Next(parameters))
        }

        @objc func methodForSelectorDoesntExist() {
            _subject.on(.Error(RxCocoaError.ObjectDoesntRespondToMessage))
        }

        @objc func errorDuringSwizzling() {
            _subject.on(.Error(RxCocoaError.ErrorDuringSwizzling))
        }

        func asObservable() -> Observable<[AnyObject]> {
            return _subject
        }

        deinit {
            _subject.on(.Completed)
        }
    }

#endif
