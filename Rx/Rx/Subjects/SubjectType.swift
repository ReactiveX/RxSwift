//
//  SubjectType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class SubjectType<SourceType, ResultType> : Observable<ResultType>, ObserverClassType {
    typealias Element = SourceType
    
    public func on(x: Event<Element>) -> Result<Void> {
        return abstractMethod()
    }
}