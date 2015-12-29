//
//  PerformanceTools.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 9/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

var mallocFunctions: [(@convention(c) (UnsafeMutablePointer<_malloc_zone_t>, Int) -> UnsafeMutablePointer<Void>)] = []

var allocCalls: Int64 = 0
var bytesAllocated: Int64 = 0

func call0(p: UnsafeMutablePointer<_malloc_zone_t>, size: Int) -> UnsafeMutablePointer<Void> {
    OSAtomicIncrement64(&allocCalls)
    OSAtomicAdd64(Int64(size), &bytesAllocated)
#if ALLOC_HOOK
    allocation()
#endif
    return mallocFunctions[0](p, size)
}

func call1(p: UnsafeMutablePointer<_malloc_zone_t>, size: Int) -> UnsafeMutablePointer<Void> {
    OSAtomicIncrement64(&allocCalls)
    OSAtomicAdd64(Int64(size), &bytesAllocated)
#if ALLOC_HOOK
    allocation()
#endif
    return mallocFunctions[1](p, size)
}

func call2(p: UnsafeMutablePointer<_malloc_zone_t>, size: Int) -> UnsafeMutablePointer<Void> {
    OSAtomicIncrement64(&allocCalls)
    OSAtomicAdd64(Int64(size), &bytesAllocated)
#if ALLOC_HOOK
    allocation()
#endif
    return mallocFunctions[2](p, size)
}

var proxies: [(@convention(c) (UnsafeMutablePointer<_malloc_zone_t>, Int) -> UnsafeMutablePointer<Void>)] = [call0, call1, call2]

func getMemoryInfo() -> (bytes: Int64, allocations: Int64) {
    return (bytesAllocated, allocCalls)
}

var registeredMallocHooks = false

func registerMallocHooks() {
    if registeredMallocHooks {
        return
    }

    registeredMallocHooks = true

    var _zones: UnsafeMutablePointer<vm_address_t> = UnsafeMutablePointer(nil)
    var count: UInt32 = 0

    // malloc_zone_print(nil, 1)
    let res = malloc_get_all_zones(mach_task_self_, nil, &_zones, &count)
    assert(res == 0)

    let zones = UnsafeMutablePointer<UnsafeMutablePointer<malloc_zone_t>>(_zones)

    assert(Int(count) <= proxies.count)

    for i in 0 ..< Int(count) {
        let zoneArray = zones.advancedBy(i)
        let name = malloc_get_zone_name(zoneArray.memory)
        var zone = zoneArray.memory.memory

        //print(String.fromCString(name))

        assert(name != nil)
        mallocFunctions.append(zone.malloc)
        zone.malloc = proxies[i]

        let protectSize = vm_size_t(sizeof(malloc_zone_t)) * vm_size_t(count)

        if true {
            let addressPointer = UnsafeMutablePointer<vm_address_t>(zoneArray)
            let res = vm_protect(mach_task_self_, addressPointer.memory, protectSize, 0, PROT_READ | PROT_WRITE)
            assert(res == 0)
        }

        zoneArray.memory.memory = zone

        if true {
            let res = vm_protect(mach_task_self_, _zones.memory, protectSize, 0, PROT_READ)
            assert(res == 0)
        }
    }
}

// MARK: Benchmark tools

let NumberOfIterations = 10000

class A {
    let _0 = 0
    let _1 = 0
    let _2 = 0
    let _3 = 0
    let _4 = 0
    let _5 = 0
    let _6 = 0
}

class B {
    var a = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29]
}

let numberOfObjects = 1000000
let aliveAtTheEnd = numberOfObjects / 10

var objects: [AnyObject] = []

func fragmentMemory() {
    objects = [AnyObject](count: aliveAtTheEnd, repeatedValue: A())
    for _ in 0 ..< numberOfObjects {
        objects[Int(arc4random_uniform(UInt32(aliveAtTheEnd)))] = arc4random_uniform(2) == 0 ? A() : B()
    }
}

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

    return approxValuePerIteration(timeInNano) / 1000
}

func measureMemoryUsage(@noescape work: () -> ()) -> (bytesAllocated: UInt64, allocations: UInt64) {
    let (bytes, allocations) = getMemoryInfo()
    for _ in 0 ..< NumberOfIterations {
        work()
    }
    let (bytesAfter, allocationsAfter) = getMemoryInfo()

    return (approxValuePerIteration(bytesAfter - bytes), approxValuePerIteration(allocationsAfter - allocations))
}

var fragmentedMemory = false

func compareTwoImplementations(benchmarkTime benchmarkTime: Bool, benchmarkMemory: Bool, @noescape first: () -> (), @noescape second: () -> ()) {
    if !fragmentedMemory {
        print("Fragmenting memory ...")
        fragmentMemory()
        print("Benchmarking ...")
        fragmentedMemory = true
    }

    // first warm up to keep it fair

    let time1: UInt64
    let time2: UInt64

    if benchmarkTime {
        first()
        second()

        time1 = measureTime(first)
        time2 = measureTime(second)
    }
    else {
        time1 = 0
        time2 = 0
    }

    let memory1: (bytesAllocated: UInt64, allocations: UInt64)
    let memory2: (bytesAllocated: UInt64, allocations: UInt64)
    if benchmarkMemory {

        registerMallocHooks()

        first()
        second()

        memory1 = measureMemoryUsage(first)
        memory2 = measureMemoryUsage(second)
    }
    else {
        memory1 = (0, 0)
        memory2 = (0, 0)
    }
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
