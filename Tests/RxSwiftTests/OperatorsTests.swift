//
//  OperatorsTests.swift
//  Rx
//
//  Created by Sebastián Varela Basconi on 11/10/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import XCTest

class OperatorsTests: RxTest { }

extension OperatorsTests {
    
    func testBindObserverToAnyObservable() {
        let disposeBag = DisposeBag()
        let observer = PublishSubject<Int>()
        let observable = BehaviorSubject<Int>(value: 2)

        observer ~> observable ~~> disposeBag

        observer.on(.next(5))
        XCTAssertEqual(try? observable.value(), 5)

        observer.on(.next(6))
        XCTAssertEqual(try? observable.value(), 6)
    }

    func testBindObservableIntoClosure() {
        let disposeBag = DisposeBag()
        let expect = expectation(description: "Receive propper value")

        let observable = Observable<Int>.create { observer in
            observer.onNext(1)
            observer.onCompleted()

            return Disposables.create()
        }

        observable ~> { value in
            if value == 1 {
                expect.fulfill()
            }
        } ~~> disposeBag

        waitForExpectations(timeout: 1)
    }
    
    func testDisposableBinding() {
        var disposeBag: DisposeBag! = DisposeBag()
        let value1 = 11
        let value2 = 22
        let value3 = 33
        let observer = PublishSubject<Int>()
        let observable = BehaviorSubject<Int>(value: value1)

        //Bind
        observer ~> observable ~~> disposeBag
        //Or: disposeBag <~~ observer ~> observable
        //Or: disposeBag <~~ observable <~ observer

        //Check relationship
        XCTAssertEqual(try? observable.value(), value1)
        observer.on(.next(value2))
        XCTAssertEqual(try? observable.value(), value2)

        //Destroy all binding
        disposeBag = nil

        //If a the observer get a new value, the observable still on last value
        observer.on(.next(value3))
        XCTAssertEqual(try? observable.value(), value2)
    }
}
