//
//  CalculatorAction.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


enum Action {
    case clear
    case changeSign
    case percent
    case operation(Operator)
    case equal
    case addNumber(Character)
    case addDot
}
