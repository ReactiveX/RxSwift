//
//  CalculatorState.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct CalculatorState {
    static let CLEAR_STATE = CalculatorState(previousNumber: nil, action: .Clear, currentNumber: "0", inScreen: "0", replace: true)

    let previousNumber: String!
    let action: Action
    let currentNumber: String!
    let inScreen: String
    let replace: Bool
}

extension CalculatorState {
    func tranformState(x: Action) -> CalculatorState {
        switch x {
        case .Clear:
            return CalculatorState.CLEAR_STATE
        case .AddNumber(let c):
            return addNumber(c)
        case .AddDot:
            return self.addDot()
        case .ChangeSign:
            let d = "\(-Double(self.inScreen)!)"
            return CalculatorState(previousNumber: previousNumber, action: action, currentNumber: d, inScreen: d, replace: true)
        case .Percent:
            let d = "\(Double(self.inScreen)!/100)"
            return CalculatorState(previousNumber: previousNumber, action: action, currentNumber: d, inScreen: d, replace: true)
        case .Operation(let o):
            return performOperation(o)
        case .Equal:
            return performEqual()
        }
    }
    
    func addNumber(char: Character) -> CalculatorState {
        let cn = currentNumber == nil || replace ? String(char) : inScreen + String(char)
        return CalculatorState(previousNumber: previousNumber, action: action, currentNumber: cn, inScreen: cn, replace: false)
    }
    
    func addDot() -> CalculatorState {
        let cn = inScreen.rangeOfString(".") == nil ? currentNumber + "." : currentNumber
        return CalculatorState(previousNumber: previousNumber, action: action, currentNumber: cn, inScreen: cn, replace: false)
    }
    
    func performOperation(o: Operator) -> CalculatorState {
        
        if previousNumber == nil {
            return CalculatorState(previousNumber: currentNumber, action: .Operation(o), currentNumber: nil, inScreen: currentNumber, replace: true)
        }
        else {
            let previous = Double(previousNumber)!
            let current = Double(inScreen)!
            
            switch action {
            case .Operation(let op):
                switch op {
                case .Addition:
                    let result = "\(previous + current)"
                    return CalculatorState(previousNumber: result, action: .Operation(o), currentNumber: nil, inScreen: result, replace: true)
                case .Subtraction:
                    let result = "\(previous - current)"
                    return CalculatorState(previousNumber: result, action: .Operation(o), currentNumber: nil, inScreen: result, replace: true)
                case .Multiplication:
                    let result = "\(previous * current)"
                    return CalculatorState(previousNumber: result, action: .Operation(o), currentNumber: nil, inScreen: result, replace: true)
                case .Division:
                    let result = "\(previous / current)"
                    return CalculatorState(previousNumber: result, action: .Operation(o), currentNumber: nil, inScreen: result, replace: true)
                }
            default:
                return CalculatorState(previousNumber: nil, action: .Operation(o), currentNumber: currentNumber, inScreen: inScreen, replace: true)
            }
            
        }
        
    }
    
    func performEqual() -> CalculatorState {
        let previous = Double(previousNumber ?? "0")
        let current = Double(inScreen)!
        
        switch action {
        case .Operation(let op):
            switch op {
            case .Addition:
                let result = "\(previous! + current)"
                return CalculatorState(previousNumber: nil, action: .Clear, currentNumber: result, inScreen: result, replace: true)
            case .Subtraction:
                let result = "\(previous! - current)"
                return CalculatorState(previousNumber: nil, action: .Clear, currentNumber: result, inScreen: result, replace: true)
            case .Multiplication:
                let result = "\(previous! * current)"
                return CalculatorState(previousNumber: nil, action: .Clear, currentNumber: result, inScreen: result, replace: true)
            case .Division:
                let result = previous! / current
                let resultText = result == Double.infinity ? "0" : "\(result)"
                return CalculatorState(previousNumber: nil, action: .Clear, currentNumber: resultText, inScreen: resultText, replace: true)
            }
        default:
            return CalculatorState(previousNumber: nil, action: .Clear, currentNumber: currentNumber, inScreen: inScreen, replace: true)
        }
    }

}