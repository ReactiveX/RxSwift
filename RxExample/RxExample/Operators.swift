//
//  Operators.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

import UIKit

// Two way binding operator between control property and variable, that's all it takes {

infix operator <-> {
}

func nonMarkedText(_ textInput: UITextInput) -> String? {
    let start = textInput.beginningOfDocument
    let end = textInput.endOfDocument

    guard let rangeAll = textInput.textRange(from: start, to: end),
        text = textInput.text(in: rangeAll) else {
            return nil
    }

    guard let markedTextRange = textInput.markedTextRange else {
        return text
    }

    guard let startRange = textInput.textRange(from: start, to: markedTextRange.start),
        endRange = textInput.textRange(from: markedTextRange.end, to: end) else {
        return text
    }

    return (textInput.text(in: startRange) ?? "") + (textInput.text(in: endRange) ?? "")
}

func <-> (textInput: RxTextInput, variable: Variable<String>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bindTo(textInput.rx_text)
    let bindToVariable = textInput.rx_text
        .subscribe(onNext: { [weak textInput] n in
            guard let textInput = textInput else {
                return
            }

            let nonMarkedTextValue = nonMarkedText(textInput)

            /**
             In some cases `textInput.textRangeFromPosition(start, toPosition: end)` will return nil even though the underlying
             value is not nil. This appears to be an Apple bug. If it's not, and we are doing something wrong, please let us know.
             The can be reproed easily if replace bottom code with 
             
             if nonMarkedTextValue != variable.value {
                variable.value = nonMarkedTextValue ?? ""
             }

             and you hit "Done" button on keyboard.
             */
            if let nonMarkedTextValue = nonMarkedTextValue where nonMarkedTextValue != variable.value {
                variable.value = nonMarkedTextValue
            }
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
}

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    if T.self == String.self {
#if DEBUG
        fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx_text` property directly to variable.\n" +
            "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
            "REMEDY: Just use `textField <-> variable` instead of `textField.rx_text <-> variable`.\n" +
            "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n"
            )
#endif
    }

    let bindToUIDisposable = variable.asObservable()
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
}

// }

