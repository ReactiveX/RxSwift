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

compareTwoImplementations(benchmarkTime: true, first: {
    let publishSubject = PublishSubject<Int>()

    //let a = just(1)

    //combineLatest(a,
        publishSubject//.asDriver(onErrorJustReturn: -1)
        .shareReplay(1)
        .map { $0 }
        .filter { _ in true }//){ x, _ in x }
        .map { $0 }
        .flatMap { just($0) }
        .subscribeNext { _ in

        }


    for i in 0..<100 {
        publishSubject.on(.Next(i))
    }

}, second: {
    
})
