//
//  ConnectableObservableType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol ConnectableObservableType : ObservableType {
    func connect() -> Disposable
}