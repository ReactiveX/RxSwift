//
//  MockWireframe.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class MockWireframe : Wireframe {
    let _openURL: (NSURL) -> ()
    let _promptFor: (String, Any, [Any]) -> Observable<Any>

    init(openURL: (NSURL) -> () = notImplementedSync(),
        promptFor: (String, Any, [Any]) -> Observable<Any> = notImplemented()) {
        _openURL = openURL
        _promptFor = promptFor
    }

    func openURL(URL: NSURL) {
        _openURL(URL)
    }

    func promptFor<Action: CustomStringConvertible>(message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        return _promptFor(message, cancelAction, actions.map { $0 as Any }).map { $0 as! Action }
    }
}
