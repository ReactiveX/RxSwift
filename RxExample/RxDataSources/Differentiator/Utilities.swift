//
//  Utilities.swift
//  RxDataSources
//
//  Created by muukii on 8/2/17.
//  Copyright © 2017 kzaher. All rights reserved.
//

import Foundation

enum DifferentiatorError : Error {
    case unwrappingOptional
    case preconditionFailed(message: String)
}

func precondition(_ condition: Bool, _ message: @autoclosure() -> String) throws -> Void {
    if condition {
        return
    }
    debugFatalError("Precondition failed")

    throw DifferentiatorError.preconditionFailed(message: message())
}

func debugFatalError(_ error: Error) {
    debugFatalError("\(error)")
}

func debugFatalError(_ message: String) {
    #if DEBUG
        fatalError(message)
    #else
        print(message)
    #endif
}
