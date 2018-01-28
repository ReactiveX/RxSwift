//
//  CalculatorViewController.swift
//  RxExample
//
//  Created by Carlos García on 4/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

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
        typealias FeedbackLoop = (ObservableSchedulerContext<CalculatorState>) -> Observable<CalculatorCommand>

        let uiFeedback: FeedbackLoop = bind(self) { this, state in
            let subscriptions = [
                state.map { $0.screen }.bind(to: this.resultLabel.rx.text),
                state.map { $0.sign }.bind(to: this.lastSignLabel.rx.text)
            ]

            let events: [Observable<CalculatorCommand>] = [
                    this.allClearButton.rx.tap.map { _ in .clear },

                    this.changeSignButton.rx.tap.map { _ in .changeSign },
                    this.percentButton.rx.tap.map { _ in .percent },

                    this.divideButton.rx.tap.map { _ in .operation(.division) },
                    this.multiplyButton.rx.tap.map { _ in .operation(.multiplication) },
                    this.minusButton.rx.tap.map { _ in .operation(.subtraction) },
                    this.plusButton.rx.tap.map { _ in .operation(.addition) },

                    this.equalButton.rx.tap.map { _ in .equal },

                    this.dotButton.rx.tap.map { _ in  .addDot },

                    this.zeroButton.rx.tap.map { _ in .addNumber("0") },
                    this.oneButton.rx.tap.map { _ in .addNumber("1") },
                    this.twoButton.rx.tap.map { _ in .addNumber("2") },
                    this.threeButton.rx.tap.map { _ in .addNumber("3") },
                    this.fourButton.rx.tap.map { _ in .addNumber("4") },
                    this.fiveButton.rx.tap.map { _ in .addNumber("5") },
                    this.sixButton.rx.tap.map { _ in .addNumber("6") },
                    this.sevenButton.rx.tap.map { _ in .addNumber("7") },
                    this.eightButton.rx.tap.map { _ in .addNumber("8") },
                    this.nineButton.rx.tap.map { _ in .addNumber("9") }
                ]

            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        Observable.system(
            initialState: CalculatorState.initial,
            reduce: CalculatorState.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback: uiFeedback
        )
            .subscribe()
            .disposed(by: disposeBag)
    }

    func formatResult(_ result: String) -> String {
        if result.hasSuffix(".0") {
            return String(result[result.startIndex ..< result.index(result.endIndex, offsetBy: -2)])
        } else {
            return result
        }
    }
}
