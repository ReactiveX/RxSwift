//
//  Operation.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


enum Operator {
    case addition
    case subtraction
    case multiplication
    case division
}

extension Operator {
    var sign: String {
        switch self {
        case .addition:         return "+"
        case .subtraction:      return "-"
        case .multiplication:   return "×"
        case .division:         return "/"
        }
    }
    
    var perform: (Double, Double) -> Double {
        switch self {
        case .addition:         return (+)
        case .subtraction:      return (-)
        case .multiplication:   return (*)
        case .division:         return (/)
        }
    }
}
