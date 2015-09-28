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

let NumberOfIterations = 1000

func approxValuePerIteration(total: Int) -> UInt64 {
    return UInt64(round(Double(total) / Double(NumberOfIterations)))
}

func approxValuePerIteration(total: UInt64) -> UInt64 {
    return UInt64(round(Double(total) / Double(NumberOfIterations)))
}

func measureTime(@noescape work: () -> ()) -> UInt64 {
    var timebaseInfo: mach_timebase_info = mach_timebase_info()
    let res = mach_timebase_info(&timebaseInfo)

    assert(res == 0)

    let start = mach_absolute_time()
    for _ in 0 ..< NumberOfIterations {
        work()
    }
    let timeInNano = (mach_absolute_time() - start) * UInt64(timebaseInfo.numer) / UInt64(timebaseInfo.denom)

    return approxValuePerIteration(timeInNano) / UInt64(NumberOfIterations)
}

func measureMemoryUsage(@noescape work: () -> ()) -> (bytesAllocated: UInt64, allocations: UInt64) {
    let (bytes, allocations) = getMemoryInfo()
    for _ in 0 ..< NumberOfIterations {
        work()
    }
    let (bytesAfter, allocationsAfter) = getMemoryInfo()

    return (approxValuePerIteration(bytesAfter - bytes), approxValuePerIteration(allocationsAfter - allocations))
}

func compareTwoImplementations(@noescape first first: () -> (), @noescape second: () -> ()) {
    // first warm up to keep it fair
    first()
    second()

    let time1 = measureTime(first)
    let time2 = measureTime(second)

    registerMallocHooks()

    let memory1 = measureMemoryUsage(first)
    let memory2 = measureMemoryUsage(second)

    // this is good enough
    print(String(format: "#1 implementation %8d bytes %4d allocations %5d useconds", arguments: [
        memory1.bytesAllocated,
        memory1.allocations,
        time1
    ]))
    print(String(format: "#2 implementation %8d bytes %4d allocations %5d useconds", arguments: [
        memory2.bytesAllocated,
        memory2.allocations,
        time2
        ]))
}

compareTwoImplementations(first: {

}, second: {
    
})
