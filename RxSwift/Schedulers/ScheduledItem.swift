//
//  ScheduledItem.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol ScheduledItemType : Cancelable {
    var time: Int {
        get
    }
    
    func invoke()
}

class ScheduledItem<T> : ScheduledItemType {
    typealias Action = T -> Disposable
    
    let action: Action
    let state: T
    let time: Int
    
    var disposed: Bool {
        get {
            return disposable.disposed
        }
    }
    
    var disposable = SingleAssignmentDisposable()
    
    init(action: Action, state: T, time: Int) {
        self.action = action
        self.state = state
        self.time = time
    }
    
    func invoke() {
         self.disposable.disposable = action(state)
    }
    
    func dispose() {
        self.disposable.dispose()
    }
}
