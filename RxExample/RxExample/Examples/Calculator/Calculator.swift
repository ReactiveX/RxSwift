//
//  Calculator.swift
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

enum CalculatorCommand {
    case clear
    case changeSign
    case percent
    case operation(Operator)
    case equal
    case addNumber(Character)
    case addDot
}

enum CalculatorState {
    case oneOperand(operand: Double, screen: String)
    case oneOperandAndOperator(operand: Double, operator: Operator, screen: String)
}

extension CalculatorState {
    static let initial = CalculatorState.oneOperand(operand: 0.0, screen: "0")

    func mapScreen(transform: (String) -> String) -> CalculatorState {
        switch self {
        case let .oneOperand(operand, screen):
            return .oneOperand(operand: operand, screen: transform(screen))
        case let .oneOperandAndOperator(operand, operat, screen):
            return .oneOperandAndOperator(operand: operand, operator: operat, screen: transform(screen))
        }
    }

    var screen: String {
        switch self {
        case let .oneOperand(_, screen):
            return screen
        case let .oneOperandAndOperator(_, _, screen):
            return screen
        }
    }

    var sign: String {
        switch self {
        case .oneOperand(_, _):
            return ""
        case let .oneOperandAndOperator(_, o, _):
            return o.sign
        }
    }
}


extension CalculatorState {
    static func reduce(state: CalculatorState, _ x: CalculatorCommand) -> CalculatorState {
        switch x {
        case .clear:
            return CalculatorState.initial
        case .addNumber(let c):
            return state.mapScreen { $0 == "0" ? String(c) : $0 + String(c) }
        case .addDot:
            return state.mapScreen { $0.range(of: ".") == nil ? $0 + "." : $0 }
        case .changeSign:
            return state.mapScreen { "\(-(Double($0) ?? 0.0))" }
        case .percent:
            return state.mapScreen { "\((Double($0) ?? 0.0) / 100.0)" }
        case .operation(let o):
            switch state {
            case let .oneOperand(_, screen):
                return .oneOperandAndOperator(operand: Double(screen) ?? 0.0, operator: o, screen: "0")
            case let .oneOperandAndOperator(operand, o, screen):
                return .oneOperandAndOperator(operand: o.perform(operand, Double(screen) ?? 0.0), operator: o, screen: "0")
            }
        case .equal:
            switch state {
            case let .oneOperandAndOperator(lhs, o, screen):
                let result = o.perform(lhs, Double(screen) ?? 0.0)
                return .oneOperand(operand: result, screen: String(result))
            default:
                return state
            }
        }
    }
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
