//
//  ScheduledItem.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

struct ScheduledItem<State>
    : ScheduledItemType
    , InvocableType {
    typealias Action = (State) -> Disposable
    
    private let action: Action
    private let state: State

    private let disposable = SingleAssignmentDisposable()

    var isDisposed: Bool {
        self.disposable.isDisposed
    }
    
    init(action: @escaping Action, state: State) {
        self.action = action
        self.state = state
    }
    
    func invoke() {
         self.disposable.setDisposable(self.action(self.state))
    }
    
    func dispose() {
        self.disposable.dispose()
    }
}
