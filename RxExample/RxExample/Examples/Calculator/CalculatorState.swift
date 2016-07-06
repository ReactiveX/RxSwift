//
//  CalculatorState.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct CalculatorState {
    static let CLEAR_STATE = CalculatorState(previousNumber: nil, action: .clear, currentNumber: "0", inScreen: "0", replace: true)

    let previousNumber: String!
    let action: Action
    let currentNumber: String!
    let inScreen: String
    let replace: Bool
}

extension CalculatorState {
    func tranformState(_ x: Action) -> CalculatorState {
        switch x {
        case .clear:
            return CalculatorState.CLEAR_STATE
        case .addNumber(let c):
            return addNumber(c)
        case .addDot:
            return self.addDot()
        case .changeSign:
            let d = "\(-Double(self.inScreen)!)"
            return CalculatorState(previousNumber: previousNumber, action: action, currentNumber: d, inScreen: d, replace: true)
        case .percent:
            let d = "\(Double(self.inScreen)!/100)"
            return CalculatorState(previousNumber: previousNumber, action: action, currentNumber: d, inScreen: d, replace: true)
        case .operation(let o):
            return performOperation(o)
        case .equal:
            return performEqual()
        }
    }
    
    func addNumber(_ char: Character) -> CalculatorState {
        let cn = currentNumber == nil || replace ? String(char) : inScreen + String(char)
        return CalculatorState(previousNumber: previousNumber, action: action, currentNumber: cn, inScreen: cn, replace: false)
    }
    
    func addDot() -> CalculatorState {
        let cn = inScreen.range(of: ".") == nil ? currentNumber + "." : currentNumber
        return CalculatorState(previousNumber: previousNumber, action: action, currentNumber: cn, inScreen: cn!, replace: false)
    }
    
    func performOperation(_ o: Operator) -> CalculatorState {
        
        if previousNumber == nil {
            return CalculatorState(previousNumber: currentNumber, action: .operation(o), currentNumber: nil, inScreen: currentNumber, replace: true)
        }
        else {
            let previous = Double(previousNumber)!
            let current = Double(inScreen)!
            
            switch action {
            case .operation(let op):
                switch op {
                case .addition:
                    let result = "\(previous + current)"
                    return CalculatorState(previousNumber: result, action: .operation(o), currentNumber: nil, inScreen: result, replace: true)
                case .subtraction:
                    let result = "\(previous - current)"
                    return CalculatorState(previousNumber: result, action: .operation(o), currentNumber: nil, inScreen: result, replace: true)
                case .multiplication:
                    let result = "\(previous * current)"
                    return CalculatorState(previousNumber: result, action: .operation(o), currentNumber: nil, inScreen: result, replace: true)
                case .division:
                    let result = "\(previous / current)"
                    return CalculatorState(previousNumber: result, action: .operation(o), currentNumber: nil, inScreen: result, replace: true)
                }
            default:
                return CalculatorState(previousNumber: nil, action: .operation(o), currentNumber: currentNumber, inScreen: inScreen, replace: true)
            }
            
        }
        
    }
    
    func performEqual() -> CalculatorState {
        let previous = Double(previousNumber ?? "0")
        let current = Double(inScreen)!
        
        switch action {
        case .operation(let op):
            switch op {
            case .addition:
                let result = "\(previous! + current)"
                return CalculatorState(previousNumber: nil, action: .clear, currentNumber: result, inScreen: result, replace: true)
            case .subtraction:
                let result = "\(previous! - current)"
                return CalculatorState(previousNumber: nil, action: .clear, currentNumber: result, inScreen: result, replace: true)
            case .multiplication:
                let result = "\(previous! * current)"
                return CalculatorState(previousNumber: nil, action: .clear, currentNumber: result, inScreen: result, replace: true)
            case .division:
                let result = previous! / current
                let resultText = result == Double.infinity ? "0" : "\(result)"
                return CalculatorState(previousNumber: nil, action: .clear, currentNumber: resultText, inScreen: resultText, replace: true)
            }
        default:
            return CalculatorState(previousNumber: nil, action: .clear, currentNumber: currentNumber, inScreen: inScreen, replace: true)
        }
    }

}
