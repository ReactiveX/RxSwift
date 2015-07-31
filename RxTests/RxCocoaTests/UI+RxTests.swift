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
            observableText.next(self.text)
        }
    }
    
    func rx_text() -> Observable<String> {
        return observableText
    }
}

class UILabelMock {
    var text: String! = ""
    
    func rx_subscribeTextTo(source: Observable<String>) -> Disposable {
        return source >- subscribeNext { t in
            self.text = t
        }
    }
}

class UIRxTests : RxTest {
    
    func testArea() {
    }
    
    func testReadmeExample() {
        
        // We have some async Wolfram Alpha API that calculates is number prime.
        let WolframAlphaIsPrime: (Int) -> Observable<PrimeNumber> = { returnElement(PrimeNumber($0, isPrime($0))) }
        
        let text = Variable<String>("")
        let resultText = ""
        
        let primeTextField = UITextFieldMock()
        
        let resultLabel = UILabelMock()
        
        let disposable = primeTextField.rx_text()
            >- map { WolframAlphaIsPrime($0.toInt() ?? 0) }
            >- concat
            >- map { "number \($0.n) is prime? \($0.isPrime)" }
            >- resultLabel.rx_subscribeTextTo
            >- scopedDispose
        
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