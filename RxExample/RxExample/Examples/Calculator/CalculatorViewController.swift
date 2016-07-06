//
//  CalculatorViewController.swift
//  RxExample
//
//  Created by Carlos García on 4/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif


class CalculatorViewController: ViewController {

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
    
    override func viewDidLoad() {
        let commands:[Observable<Action>] = [
            allClearButton.rx_tap.map { _ in .clear },
            
            changeSignButton.rx_tap.map { _ in .changeSign },
            percentButton.rx_tap.map { _ in .percent },
            
            divideButton.rx_tap.map { _ in .operation(.division) },
            multiplyButton.rx_tap.map { _ in .operation(.multiplication) },
            minusButton.rx_tap.map { _ in .operation(.subtraction) },
            plusButton.rx_tap.map { _ in .operation(.addition) },
            
            equalButton.rx_tap.map { _ in .equal },
            
            dotButton.rx_tap.map { _ in  .addDot },
            
            zeroButton.rx_tap.map { _ in .addNumber("0") },
            oneButton.rx_tap.map { _ in .addNumber("1") },
            twoButton.rx_tap.map { _ in .addNumber("2") },
            threeButton.rx_tap.map { _ in .addNumber("3") },
            fourButton.rx_tap.map { _ in .addNumber("4") },
            fiveButton.rx_tap.map { _ in .addNumber("5") },
            sixButton.rx_tap.map { _ in .addNumber("6") },
            sevenButton.rx_tap.map { _ in .addNumber("7") },
            eightButton.rx_tap.map { _ in .addNumber("8") },
            nineButton.rx_tap.map { _ in .addNumber("9") }
        ]
        
        commands
            .toObservable()
            .merge()
            .scan(CalculatorState.CLEAR_STATE) { a, x in
                return a.tranformState(x)
            }
            .debug("debugging")
            .subscribeNext { [weak self] calState in
                self?.resultLabel.text = calState.inScreen
                switch calState.action {
                case .operation(let operation):
                    switch operation {
                    case .addition:
                        self?.lastSignLabel.text = "+"
                    case .subtraction:
                        self?.lastSignLabel.text = "-"
                    case .multiplication:
                        self?.lastSignLabel.text = "x"
                    case .division:
                        self?.lastSignLabel.text = "/"
                    }
                default:
                    self?.lastSignLabel.text = ""
                }
            }
            .addDisposableTo(disposeBag)
    }
    
//swifts string api sucks

    func prettyFormat(str: String) -> String {
        if str.hasSuffix(".0") {
//            return str[str.startIndex..<str.endIndex.pre]
        }
        return str
    }
}





