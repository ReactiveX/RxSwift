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

// Two way binding operator between control property and variable, that's all it takes {

infix operator <-> {
}

// Usage: textField.rx_text <-> viewModel.variable

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
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

/*  Two way binding of dissimilar types with tuples
    Usage binding to optional String variable:

    (textField.rx_text, { (text) -> String in
        return text
    })
    <->
    (viewModel.variable, { (optionalValue) -> String in
        if let value = optionalValue {
            return value
        }
        
        return ""
    })
*/

func <-> <T, E>(controlTuple: (property: ControlProperty<T>, map: (T -> E)), variableTuple: (variable: Variable<E>, map: (E -> T))) -> Disposable {
    
    let (property, propertyMapClosure) = controlTuple
    let (variable, variableMapClosure) = variableTuple
    
    let bindToUIDisposable = variable.asObservable().map(variableMapClosure)
        .bindTo(property)
    let bindToVariable = property
        .map(propertyMapClosure).subscribe(onNext: { n in
            variable.value = n
            }, onCompleted:  {
                bindToUIDisposable.dispose()
        })
    
    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
}

// }