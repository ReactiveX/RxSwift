//
//  UI+RxTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 5/3/15.
//
//

import Foundation
import RxSwift
import RxCocoa
import XCTest

class UITextFieldMock {
    
    let observableText = Variable<String>("")
    
    var text: String! = "" {
        didSet {
            observableText.value = self.text
        }
    }
    
    func rx_text() -> Observable<String> {
        return observableText.asObservable()
    }
}

extension ObservableType where E == String {
    func subscribeTextOf(label: UILabelMock) -> Disposable {
        return self.subscribeNext { t in
            label.text = t
        }
    }
}

class UILabelMock {
    var text: String! = ""
    
}

class UIRxTests : RxTest {
    
    func testArea() {
    }
    
    func testReadmeExample() {
        
        // We have some async Wolfram Alpha API that calculates is number prime.
        let WolframAlphaIsPrime: (Int) -> Observable<PrimeNumber> = { just(PrimeNumber($0, isPrime($0))) }
        
        let primeTextField = UITextFieldMock()
        
        let resultLabel = UILabelMock()
        
        let _ = primeTextField.rx_text()
            .map { WolframAlphaIsPrime(Int($0) ?? 0) }
            .concat()
            .map { "number \($0.n) is prime? \($0.isPrime)" }
            .subscribeTextOf(resultLabel)
            .scopedDispose()

        // this will set resultLabel.text! == "number 43 is prime? true"
        primeTextField.text = "43"
    }
}

struct PrimeNumber : Equatable {
    let n: Int
    let isPrime: Bool
    
    init(_ n: Int, _ isPrime: Bool) {
        self.n = n
        self.isPrime = isPrime
    }
}

func == (lhs: PrimeNumber, rhs: PrimeNumber) -> Bool {
    return lhs.n == rhs.n && lhs.isPrime == rhs.isPrime
}