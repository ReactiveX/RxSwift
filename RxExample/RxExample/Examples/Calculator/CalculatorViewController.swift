//
//  CalculatorViewController.swift
//  RxExample
//
//  Created by Carlos García on 4/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class CalculatorViewController: ViewController {
    @IBOutlet var lastSignLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!

    @IBOutlet var allClearButton: UIButton!
    @IBOutlet var changeSignButton: UIButton!
    @IBOutlet var percentButton: UIButton!

    @IBOutlet var divideButton: UIButton!
    @IBOutlet var multiplyButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var equalButton: UIButton!

    @IBOutlet var dotButton: UIButton!

    @IBOutlet var zeroButton: UIButton!
    @IBOutlet var oneButton: UIButton!
    @IBOutlet var twoButton: UIButton!
    @IBOutlet var threeButton: UIButton!
    @IBOutlet var fourButton: UIButton!
    @IBOutlet var fiveButton: UIButton!
    @IBOutlet var sixButton: UIButton!
    @IBOutlet var sevenButton: UIButton!
    @IBOutlet var eightButton: UIButton!
    @IBOutlet var nineButton: UIButton!

    override func viewDidLoad() {
        typealias FeedbackLoop = (ObservableSchedulerContext<CalculatorState>) -> Observable<CalculatorCommand>

        let uiFeedback: FeedbackLoop = bind(self) { this, state in
            let subscriptions = [
                state.map(\.screen).bind(to: this.resultLabel.rx.text),
                state.map(\.sign).bind(to: this.lastSignLabel.rx.text),
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

                this.dotButton.rx.tap.map { _ in .addDot },

                this.zeroButton.rx.tap.map { _ in .addNumber("0") },
                this.oneButton.rx.tap.map { _ in .addNumber("1") },
                this.twoButton.rx.tap.map { _ in .addNumber("2") },
                this.threeButton.rx.tap.map { _ in .addNumber("3") },
                this.fourButton.rx.tap.map { _ in .addNumber("4") },
                this.fiveButton.rx.tap.map { _ in .addNumber("5") },
                this.sixButton.rx.tap.map { _ in .addNumber("6") },
                this.sevenButton.rx.tap.map { _ in .addNumber("7") },
                this.eightButton.rx.tap.map { _ in .addNumber("8") },
                this.nineButton.rx.tap.map { _ in .addNumber("9") },
            ]

            return Bindings(subscriptions: subscriptions, events: events)
        }

        Observable.system(
            initialState: CalculatorState.initial,
            reduce: CalculatorState.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback: uiFeedback,
        )
        .subscribe()
        .disposed(by: disposeBag)
    }

    func formatResult(_ result: String) -> String {
        if result.hasSuffix(".0") {
            String(result[result.startIndex ..< result.index(result.endIndex, offsetBy: -2)])
        } else {
            result
        }
    }
}
