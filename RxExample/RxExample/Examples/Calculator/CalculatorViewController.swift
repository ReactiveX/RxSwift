//
//  CalculatorViewController.swift
//  RxExample
//
//  Created by Carlos García on 4/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class CalculatorViewController: ViewController {
    
    enum Operator {
        case Addition
        case Subtraction
        case Multiplication
        case Division
    }
    
    enum Action {
        case Clear
        case ChangeSign
        case Percent
        case Operation(Operator)
        case Equal
        case AddNumber(Character)
        case AddDot
    }
    
    struct CalState {
        let previousNumber: String!
        let action: Action
        let currentNumber: String!
        let inScreen: String
        let replace: Bool
    }
    
    @IBOutlet weak var lastSignLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var allClearButton: UIButton!
    @IBOutlet weak var changeSignButton: UIButton!
    @IBOutlet weak var percentButton: UIButton!
    
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var equalButton: UIButton!
    
    @IBOutlet weak var dotButton: UIButton!
    
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    
    let CLEAR_STATE = CalState(previousNumber: nil, action: .Clear, currentNumber: "0", inScreen: "0", replace: true)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        let commands:[Observable<Action>] = [
            allClearButton.rx_tap.map { _ in .Clear },
            
            changeSignButton.rx_tap.map { _ in .ChangeSign },
            percentButton.rx_tap.map { _ in .Percent },
            
            divideButton.rx_tap.map { _ in .Operation(.Division) },
            multiplyButton.rx_tap.map { _ in .Operation(.Multiplication) },
            minusButton.rx_tap.map { _ in .Operation(.Subtraction) },
            plusButton.rx_tap.map { _ in .Operation(.Addition) },
            
            equalButton.rx_tap.map { _ in .Equal },
            
            dotButton.rx_tap.map { _ in .AddDot },
            
            zeroButton.rx_tap.map { _ in .AddNumber("0") },
            oneButton.rx_tap.map { _ in .AddNumber("1") },
            twoButton.rx_tap.map { _ in .AddNumber("2") },
            threeButton.rx_tap.map { _ in .AddNumber("3") },
            fourButton.rx_tap.map { _ in .AddNumber("4") },
            fiveButton.rx_tap.map { _ in .AddNumber("5") },
            sixButton.rx_tap.map { _ in .AddNumber("6") },
            sevenButton.rx_tap.map { _ in .AddNumber("7") },
            eightButton.rx_tap.map { _ in .AddNumber("8") },
            nineButton.rx_tap.map { _ in .AddNumber("9") }
        ]
        
        commands
            .toObservable()
            .merge()
            .scan(CLEAR_STATE) { [unowned self] a, x in
                return self.tranformState(a, x)
            }
            .debug("debugging")
            .subscribeNext { [weak self] calState in
                self?.resultLabel.text = self?.prettyFormat(calState.inScreen)
                switch calState.action {
                case .Operation(let operation):
                    switch operation {
                    case .Addition:
                        self?.lastSignLabel.text = "+"
                    case .Subtraction:
                        self?.lastSignLabel.text = "-"
                    case .Multiplication:
                        self?.lastSignLabel.text = "x"
                    case .Division:
                        self?.lastSignLabel.text = "/"
                    }
                default:
                    self?.lastSignLabel.text = ""
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func tranformState(a: CalState, _ x: Action) -> CalState {
        switch x {
        case .Clear:
            return CLEAR_STATE
        case .AddNumber(let c):
            return addNumber(a, c)
        case .AddDot:
            return addDot(a)
        case .ChangeSign:
            let d = "\(-Double(a.inScreen)!)"
            return CalState(previousNumber: a.previousNumber, action: a.action, currentNumber: d, inScreen: d, replace: true)
        case .Percent:
            let d = "\(Double(a.inScreen)!/100)"
            return CalState(previousNumber: a.previousNumber, action: a.action, currentNumber: d, inScreen: d, replace: true)
        case .Operation(let o):
            return performOperation(a, o)
        case .Equal:
            return performEqual(a)
        }
    }
    
    func addNumber(a: CalState, _ char: Character) -> CalState {
        let cn = a.currentNumber == nil || a.replace ? String(char) : a.inScreen + String(char)
        return CalState(previousNumber: a.previousNumber, action: a.action, currentNumber: cn, inScreen: cn, replace: false)
    }
    
    func addDot(a: CalState) -> CalState {
        let cn = a.inScreen.rangeOfString(".") == nil ? a.currentNumber + "." : a.currentNumber
        return CalState(previousNumber: a.previousNumber, action: a.action, currentNumber: cn, inScreen: cn, replace: false)
    }
    
    func performOperation(a: CalState, _ o: Operator) -> CalState {
        
        if a.previousNumber == nil {
            return CalState(previousNumber: a.currentNumber, action: .Operation(o), currentNumber: nil, inScreen: a.currentNumber, replace: true)
        }
        else {
            let previous = Double(a.previousNumber)!
            let current = Double(a.inScreen)!
            
            switch a.action {
            case .Operation(let op):
                switch op {
                case .Addition:
                    let result = "\(previous + current)"
                    return CalState(previousNumber: result, action: .Operation(o), currentNumber: nil, inScreen: result, replace: true)
                case .Subtraction:
                    let result = "\(previous - current)"
                    return CalState(previousNumber: result, action: .Operation(o), currentNumber: nil, inScreen: result, replace: true)
                case .Multiplication:
                    let result = "\(previous * current)"
                    return CalState(previousNumber: result, action: .Operation(o), currentNumber: nil, inScreen: result, replace: true)
                case .Division:
                    let result = "\(previous / current)"
                    return CalState(previousNumber: result, action: .Operation(o), currentNumber: nil, inScreen: result, replace: true)
                }
            default:
                return CalState(previousNumber: nil, action: .Operation(o), currentNumber: a.currentNumber, inScreen: a.inScreen, replace: true)
            }
            
        }
        
    }
    
    func performEqual(a: CalState) -> CalState {
        let previous = Double(a.previousNumber ?? "0")
        let current = Double(a.inScreen)!
        
        switch a.action {
        case .Operation(let op):
            switch op {
            case .Addition:
                let result = "\(previous! + current)"
                return CalState(previousNumber: nil, action: .Clear, currentNumber: result, inScreen: result, replace: true)
            case .Subtraction:
                let result = "\(previous! - current)"
                return CalState(previousNumber: nil, action: .Clear, currentNumber: result, inScreen: result, replace: true)
            case .Multiplication:
                let result = "\(previous! * current)"
                return CalState(previousNumber: nil, action: .Clear, currentNumber: result, inScreen: result, replace: true)
            case .Division:
                let result = previous! / current
                let resultText = result == Double.infinity ? "0" : "\(result)"
                return CalState(previousNumber: nil, action: .Clear, currentNumber: resultText, inScreen: resultText, replace: true)
            }
        default:
            return CalState(previousNumber: nil, action: .Clear, currentNumber: a.currentNumber, inScreen: a.inScreen, replace: true)
        }
    }
    
    
    func prettyFormat(str: String) -> String {
        if str.hasSuffix(".0") {
            return str.substringToIndex(str.endIndex.predecessor().predecessor())
        }
        return str
    }
}





