//
//  DataSources.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 1/8/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum RxDataSourceError : Error {
  case preconditionFailed(message: String)
}

func rxPrecondition(_ condition: Bool, _ message: @autoclosure() -> String) throws -> () {
  if condition {
    return
  }
  rxDebugFatalError("Precondition failed")

  throw RxDataSourceError.preconditionFailed(message: message())
}

func rxDebugFatalError(_ error: Error) {
  rxDebugFatalError("\(error)")
}

func rxDebugFatalError(_ message: String) {
  #if DEBUG
    fatalError(message)
  #else
    print(message)
  #endif
}
