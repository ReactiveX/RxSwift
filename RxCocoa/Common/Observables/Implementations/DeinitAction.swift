//
//  DeinitAction.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DeinitAction {
    typealias Action = () -> Void
    
    let action: Action
    init(action: Action) {
        self.action = action
    }
    
    deinit {
        self.action()
    }
}