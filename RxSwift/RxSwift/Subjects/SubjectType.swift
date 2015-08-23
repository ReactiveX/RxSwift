//
//  SubjectType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol SubjectType : ObservableType {
    typealias SubjectObserverType : ObserverType
    
    func asObserver() -> SubjectObserverType
}