//
//  PerformanceTools.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 9/27/15.
//
//

import Foundation

var mallocFunctions: [(@convention(c) (UnsafeMutablePointer<_malloc_zone_t>, Int) -> UnsafeMutablePointer<Void>)] = []

var allocCalls: Int64 = 0
var bytesAllocated: Int64 = 0

func call0(p: UnsafeMutablePointer<_malloc_zone_t>, size: Int) -> UnsafeMutablePointer<Void> {
    OSAtomicIncrement64(&allocCalls)
    OSAtomicAdd64(Int64(size), &bytesAllocated)
    return mallocFunctions[0](p, size)
}

func call1(p: UnsafeMutablePointer<_malloc_zone_t>, size: Int) -> UnsafeMutablePointer<Void> {
    OSAtomicIncrement64(&allocCalls)
    OSAtomicAdd64(Int64(size), &bytesAllocated)
    return mallocFunctions[1](p, size)
}

func call2(p: UnsafeMutablePointer<_malloc_zone_t>, size: Int) -> UnsafeMutablePointer<Void> {
    OSAtomicIncrement64(&allocCalls)
    OSAtomicAdd64(Int64(size), &bytesAllocated)
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

