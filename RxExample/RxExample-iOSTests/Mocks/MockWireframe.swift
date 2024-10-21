//
//  MockWireframe.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import Foundation

class MockWireframe: Wireframe {
    let _openURL: @Sendable (URL) -> Void
    let _promptFor: @Sendable (String, Any, [Any]) -> Observable<Any>

    init(openURL: @escaping @Sendable (URL) -> Void = notImplementedSync(),
         promptFor: @escaping @Sendable (String, Any, [Any]) -> Observable<Any> = notImplemented()) {
        _openURL = openURL
        _promptFor = promptFor
    }

    func open(url: URL) {
        _openURL(url)
    }

    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        _promptFor(message, cancelAction, actions.map { $0 as Any }).map { $0 as! Action }
    }
}
