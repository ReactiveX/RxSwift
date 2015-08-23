//
//  Deallocating.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if !DISABLE_SWIZZLING
class Deallocating : NSObject
                   , RXDeallocating {
    typealias DeallocatingAction = () -> ()
    
    let deallocatingAction: DeallocatingAction
    
    init(deallocatingAction: DeallocatingAction) {
        self.deallocatingAction = deallocatingAction
    }
    
    func deallocating() {
        deallocatingAction()
    }
}
#endif
