//
//  VirtualTimeConverterType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

public protocol VirtualTimeConverterType {
    typealias VirtualTimeUnit : Comparable
    typealias VirtualTimeIntervalUnit : Comparable

    func convertFromVirtualTime(virtualTime: VirtualTimeUnit) -> RxTime
    func convertToVirtualTime(time: RxTime) -> VirtualTimeUnit

    func convertFromTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval
    func convertToTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval

    func addVirtualTimeAndTimeInterval(time time: VirtualTimeUnit, timeInterval: VirtualTimeIntervalUnit) -> VirtualTimeUnit

    func nearFuture(time: VirtualTimeUnit) -> VirtualTimeUnit
}