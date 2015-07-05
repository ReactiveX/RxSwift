//
//  NSObject+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

extension NSObject {
    public func rx_observe<Element>(path: String) -> Observable<Element?> {
        return KVOObservable(object: self, path: path)
    }

    public func rx_observe<Element>(path: String, options: NSKeyValueObservingOptions) -> Observable<Element?> {
        return KVOObservable(object: self, path: path, options: options)
    }
}