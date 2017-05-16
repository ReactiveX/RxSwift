//
//  MockWireframe.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import struct Foundation.URL

class MockWireframe : Wireframe {
    let _openURL: (URL) -> ()
    let _promptFor: (String, Any, [Any]) -> Observable<Any>

    init(openURL: @escaping (URL) -> () = notImplementedSync(),
        promptFor: @escaping (String, Any, [Any]) -> Observable<Any> = notImplemented()) {
        _openURL = openURL
        _promptFor = promptFor
    }

    func open(url: URL) {
        _openURL(url)
    }

    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        return _promptFor(message, cancelAction, actions.map { $0 as Any }).map { $0 as! Action }
    }
}
