//
//  CalculatorAction.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum Action {
    case Clear
    case ChangeSign
    case Percent
    case Operation(Operator)
    case Equal
    case AddNumber(Character)
    case AddDot
}