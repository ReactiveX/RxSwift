//
//  HistoricalScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class HistoricalScheduler : VirtualTimeScheduler<HistoricalSchedulerTimeConverter> {

    public init(initialClock: RxTime = NSDate(timeIntervalSince1970: 0)) {
        //print(initialClock)
        super.init(initialClock: initialClock, converter: HistoricalSchedulerTimeConverter())
    }
    
}