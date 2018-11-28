//
//  ObservableRelayType.swift
//  RxCocoa
//
//  Created by Luciano Almeida on 27/11/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// `ObservableRelayType` is an ObservableType that accepts events and emits them to its subscribers.
///
/// See `BehaviorRelay` and `PublishRelay`.
public protocol ObservableRelayType: ObservableType {
    func accept(_ event: E)
}
