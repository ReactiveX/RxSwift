//
//  main.swift
//  Tests
//
//  Created by Krunoslav Zaher on 9/26/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
#if !SWIFT_PACKAGE
#endif
import AppKit
import CoreLocation

let bechmarkTime = true

func allocation() {
    
}

let iterations = 10

repeat {
    compareTwoImplementations(benchmarkTime: true, benchmarkMemory: false, first: {
//        var sum = 0
//        for _ in 0 ..< iterations {
//            var last = Observable.combineLatest(
//                Observable<Int>.create { observer in
//                    for _ in 0 ..< 1 {
//                        observer.on(.next(1))
//                    }
//                    return Disposables.create()
//            }, Observable.just(1), Observable.just(1), Observable.just(1)) { x, _, _ ,_ in x }
//
//            for _ in 0 ..< 2 {
//                last = Observable.combineLatest(last, Observable.just(1), Observable.just(1), Observable.just(1)) { x, _, _ ,_ in x }
//            }
//
//            let subscription = last
//                .subscribe(onNext: { x in
//                    sum += x
//                })
//
//            subscription.dispose()
//        }

    }, second: {
        var sum = 0
                let subscription = Observable<Int>.createAnonymous { observer in
                    for _ in 0 ..< iterations * 10 {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                    }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .subscribe(onNext: { x in
                        sum += x
                    })

                subscription.dispose()
    })
} while true
