//
//  ObservableType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol ObservableType {
    typealias E
    
    /// Subscribes `observer` to receive events from this observable
    func subscribe<O: ObserverType where O.E == E>(observer: O) -> Disposable
    
    func asObservable() -> Observable<E>
}