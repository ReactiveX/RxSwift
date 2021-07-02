//
//  ScheduledItem.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

struct ScheduledItem<Element>
    : ScheduledItemType
    , InvocableType {
    typealias Action = (Element) -> Disposable
    
    private let action: Action
    private let state: Element

    private let disposable = SingleAssignmentDisposable()

    var isDisposed: Bool {
        self.disposable.isDisposed
    }
    
    init(action: @escaping Action, state: Element) {
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
