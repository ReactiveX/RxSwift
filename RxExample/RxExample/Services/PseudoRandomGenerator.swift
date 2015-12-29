//
//  PseudoRandomGenerator.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


// https://en.wikipedia.org/wiki/Random_number_generation
class PseudoRandomGenerator {
    var m_w: UInt32    /* must not be zero, nor 0x464fffff */
    var m_z: UInt32    /* must not be zero, nor 0x9068ffff */
    
    init(_ m_w: UInt32, _ m_z: UInt32) {
        self.m_w = m_w
        self.m_z = m_z
    }
    
    func get_random() -> Int {
        m_z = 36969 &* (m_z & 65535) &+ (m_z >> 16);
        m_w = 18000 &* (m_w & 65535) &+ (m_w >> 16);
        let val = ((m_z << 16) &+ m_w)
        return Int(val % (1 << 30))  /* 32-bit result */
    }
}

