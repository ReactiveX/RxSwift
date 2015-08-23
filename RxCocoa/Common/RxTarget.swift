//
//  RxTarget.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

class RxTarget : NSObject
               , Disposable {
    
    private var retainSelf: RxTarget?
    
    override init() {
        super.init()
        self.retainSelf = self
        MainScheduler.ensureExecutingOnScheduler()
    }
    
    func dispose() {
        MainScheduler.ensureExecutingOnScheduler()
        self.retainSelf = nil
    }
}