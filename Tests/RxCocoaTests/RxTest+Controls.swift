//
//  RxTest+Controls.swift
//  Tests
//
//  Created by Krunoslav Zaher on 3/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import RxRelay
import XCTest

extension RxTest {
    func ensurePropertyDeallocated<C, T: Equatable>(
        _ createControl: () -> C,
        _ initialValue: T,
        file: StaticString = #file,
        line: UInt = #line,
        _ propertySelector: (C) -> ControlProperty<T>
    ) where C: NSObject {
        ensurePropertyDeallocated(createControl, initialValue, comparer: ==, file: file, line: line, propertySelector)
    }

    func ensurePropertyDeallocated<C, T>(
        _ createControl: () -> C,
        _ initialValue: T,
        comparer: (T, T) -> Bool,
        file: StaticString = #file,
        line: UInt = #line,
        _ propertySelector: (C) -> ControlProperty<T>
    ) where C: NSObject  {

        let relay = BehaviorRelay(value: initialValue)

        let completeExpectation = XCTestExpectation(description: "completion")
        let deallocateExpectation = XCTestExpectation(description: "deallocation")
        var lastReturnedPropertyValue: T?

        autoreleasepool {
            var control: C! = createControl()

            let property = propertySelector(control)

            let disposable = relay.bind(to: property)

            _ = property.subscribe(onNext: { n in
                lastReturnedPropertyValue = n
            }, onCompleted: {
                completeExpectation.fulfill()
                disposable.dispose()
            })


            _ = (control as NSObject).rx.deallocated.subscribe(onNext: { _ in
                deallocateExpectation.fulfill()
            })

            control = nil
        }

        wait(for: [completeExpectation, deallocateExpectation], timeout: 3.0, enforceOrder: false)

        XCTAssertTrue(
            lastReturnedPropertyValue.map { comparer(initialValue, $0) } ?? false,
            "last property value (\(lastReturnedPropertyValue.map { "\($0)" } ?? "nil"))) does not match initial value (\(initialValue))",
            file: file,
            line: line
        )
    }

    func ensureEventDeallocated<C, T>(_ createControl: @escaping () -> C, file: StaticString = #file, line: UInt = #line, _ eventSelector: (C) -> ControlEvent<T>) where C: NSObject {
        ensureEventDeallocated({ () -> (C, Disposable) in (createControl(), Disposables.create()) }, file: file, line: line, eventSelector)
    }

    func ensureEventDeallocated<C, T>(_ createControl: () -> (C, Disposable), file: StaticString = #file, line: UInt = #line, _ eventSelector: (C) -> ControlEvent<T>) where C: NSObject {
        var completed = false
        var deallocated = false
        let outerDisposable = SingleAssignmentDisposable()

        autoreleasepool {
            let (control, disposable) = createControl()
            let eventObservable = eventSelector(control)

            _ = eventObservable.subscribe(onNext: { n in

            }, onCompleted: {
                completed = true
            })

            _ = (control as NSObject).rx.deallocated.subscribe(onNext: { _ in
                deallocated = true
            })

            outerDisposable.setDisposable(disposable)
        }

        outerDisposable.dispose()
        XCTAssertTrue(deallocated, "event not deallocated", file: file, line: line)
        XCTAssertTrue(completed, "event not completed", file: file, line: line)
    }

    func ensureControlObserverHasWeakReference<C, T>(file: StaticString = #file, line: UInt = #line, _ createControl: @autoclosure() -> (C), _ observerSelector: (C) -> AnyObserver<T>, _ observableSelector: () -> (Observable<T>)) where C: NSObject {
        var deallocated = false

        let disposeBag = DisposeBag()

        autoreleasepool {
            let control = createControl()
            let propertyObserver = observerSelector(control)
            let observable = observableSelector()

            observable.bind(to: propertyObserver).disposed(by: disposeBag)

            _ = (control as NSObject).rx.deallocated.subscribe(onNext: { _ in
                deallocated = true
            })
        }

        XCTAssertTrue(deallocated, "control observer reference is over-retained", file: file, line: line)
    }
}
