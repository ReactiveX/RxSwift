//
//  DataSources.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 1/8/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum RxDataSourceError : ErrorProtocol {
    case UnwrappingOptional
    case PreconditionFailed(message: String)
}

func rxPrecondition(condition: Bool, @autoclosure _ message: () -> String) throws -> () {
    if condition {
        return
    }
    rxDebugFatalError("Precondition failed")

    throw RxDataSourceError.PreconditionFailed(message: message())
}

func rxDebugFatalError(error: ErrorProtocol) {
    rxDebugFatalError("\(error)")
}

func rxDebugFatalError(message: String) {
    #if DEBUG
        fatalError(message)
    #else
        print(message)
    #endif
}