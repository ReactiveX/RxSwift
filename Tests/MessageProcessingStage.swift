//
//  MessageProcessingStage.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/2/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift

enum MessageProcessingStage: Int {
    // message is first sent to an objet
    case sentMessage = 0
    // ... then it's being invoked
    case invoking = 1
    // ... and after method is invoked
    case methodInvoked = 2
}

typealias MethodParameters = [Any]

struct ObservedSequence {
    let stage: MessageProcessingStage
    let sequence: Observable<MethodParameters>

    static func sentMessage(_ sequence: Observable<MethodParameters>) -> ObservedSequence {
        return ObservedSequence(stage: .sentMessage, sequence: sequence)
    }

    static func invoking(_ sequence: Observable<MethodParameters>) -> ObservedSequence {
        return ObservedSequence(stage: .invoking, sequence: sequence)
    }

    static func methodInvoked(_ sequence: Observable<MethodParameters>) -> ObservedSequence {
        return ObservedSequence(stage: .methodInvoked, sequence: sequence)
    }
}
