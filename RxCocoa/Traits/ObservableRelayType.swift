//
//  ObservableRelayType.swift
//  RxCocoa
//
//  Created by Luciano Almeida on 25/11/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// `ObservableRelayType` is an ObservableType that accepts events and emits it to subscribers.
///  See `PublishRelay` and `BehaviorRelay`.
public protocol ObservableRelayType: ObservableType {
    func accept(_ event: E)
}
