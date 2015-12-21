//
//  main.swift
//  Benchmark
//
//  Created by Krunoslav Zaher on 9/26/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AppKit
import CoreLocation

let bechmarkTime = true

func allocation() {
    
}

repeat {
compareTwoImplementations(benchmarkTime: true, benchmarkMemory: false, first: {
    let publishSubject = PublishSubject<Int>()

    //let a = Observable.just(1)

    //combineLatest(a,
        publishSubject //.asDriver(onErrorJustReturn: -1)
    /*create { (o: AnyObserver<Int>) in
            for i in 0..<100 {
                o.on(.Next(i))
            }
            return NopDisposable.instance
        }*/
        //.retryWhen { $0 }
        .shareReplay(1)
        .shareReplay(1)
        .shareReplay(1)
        .shareReplay(1)
        .shareReplay(1)
        .shareReplay(1)
        .shareReplay(1)
        .shareReplay(1)
        //.map { $0 }
        /*.map { $0 }
        .map { $0 }
        .map { $0 }
        .map { $0 }*/
        /*.filter { _ in true }//){ x, _ in x }
        .map { $0 }
        .flatMap { Observable.just($0) }*/
        .subscribeNext { _ in

        }


    for i in 0..<100 {
        publishSubject.on(.Next(i))
    }

}, second: {
    
})
} while true