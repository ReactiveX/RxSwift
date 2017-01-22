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
            allClearButton.rx.tap.map { _ in .clear },
            
            changeSignButton.rx.tap.map { _ in .changeSign },
            percentButton.rx.tap.map { _ in .percent },
            
            divideButton.rx.tap.map { _ in .operation(.division) },
            multiplyButton.rx.tap.map { _ in .operation(.multiplication) },
            minusButton.rx.tap.map { _ in .operation(.subtraction) },
            plusButton.rx.tap.map { _ in .operation(.addition) },
            
            equalButton.rx.tap.map { _ in .equal },
            
            dotButton.rx.tap.map { _ in  .addDot },
            
            zeroButton.rx.tap.map { _ in .addNumber("0") },
            oneButton.rx.tap.map { _ in .addNumber("1") },
            twoButton.rx.tap.map { _ in .addNumber("2") },
            threeButton.rx.tap.map { _ in .addNumber("3") },
            fourButton.rx.tap.map { _ in .addNumber("4") },
            fiveButton.rx.tap.map { _ in .addNumber("5") },
            sixButton.rx.tap.map { _ in .addNumber("6") },
            sevenButton.rx.tap.map { _ in .addNumber("7") },
            eightButton.rx.tap.map { _ in .addNumber("8") },
            nineButton.rx.tap.map { _ in .addNumber("9") }
        ]
        
        Observable.from(commands)
            .merge()
            .scan(CalculatorState.CLEAR_STATE) { previous, action in
                previous.tranformState(action)
            }
            .debug("calculator state")
            .subscribe(onNext: { [weak self] calState in
                self?.resultLabel.text = self?.formatResult(calState.inScreen)
                
                if case let .operation(operation) = calState.action {
                    self?.lastSignLabel.text = operation.sign
                } else {
                    self?.lastSignLabel.text = ""
                }
            })
            .disposed(by: disposeBag)
    }

    func formatResult(_ result: String) -> String {
        if result.hasSuffix(".0") {
            return result.substring(to: result.index(result.endIndex, offsetBy: -2))
        } else {
            return result
        }
    }
}
