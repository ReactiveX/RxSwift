//
//  InvocableType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 11/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol InvocableType {
    func invoke()
}

protocol InvocableWithValueType {
    
    typealias Value

    func invoke(_ value: Value)
}
