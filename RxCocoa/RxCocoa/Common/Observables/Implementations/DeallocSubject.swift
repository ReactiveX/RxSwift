//
//  DeallocSubject.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

func createDeallocDisposable(action: PublishSubject<Void> -> Void) -> DeallocSubject<Void> {
    return DeallocSubject { s in
        if !s.disposed {
            action(s)
        }
    }
}

// classes derived from generic classes must also be generic :(
class DeallocSubject<T> : PublishSubject<T> {
    typealias DisposeAction = (DeallocSubject<T>) -> ()
    
    let disposeAction: DisposeAction
    
    init(disposeAction: DisposeAction) {
        self.disposeAction = disposeAction
    }
    
    // We can be sure that nothing can change this value because only one thread
    // is executing dispose, and any other thread can't have any strong reference to object.
    // Somebody could still have a unowned reference to this object, but since this object
    // isn't public and is used in a controlled environment, we can be sure while this code
    // is being executed nobody is mutating it's state.
    deinit {
        disposeAction(self)
    }
}