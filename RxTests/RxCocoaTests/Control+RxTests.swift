//
//  Control+RxTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 10/18/15.
//
//

import Foundation
import RxCocoa
import RxSwift
import XCTest

class ControlTests : RxTest {

    func ensurePropertyDeallocated<C, T: Equatable where C: NSObject>(createControl: () -> C, _ initialValue: T, _ propertySelector: C -> ControlProperty<T>) {
        let variable = Variable(initialValue)


        var completed = false
        var deallocated = false
        var lastReturnedPropertyValue: T!

        autoreleasepool {
            var control: C! = createControl()

            let property = propertySelector(control)

            let disposable = variable.bindTo(property)

            _ = property.subscribe(onNext: { n in
                lastReturnedPropertyValue = n
            }, onCompleted: {
                completed = true
                disposable.dispose()
            })


            _ = control.rx_deallocated.subscribeNext { _ in
                deallocated = true
            }

            control = nil
        }

        XCTAssertTrue(deallocated)
        XCTAssertTrue(completed)
        XCTAssertEqual(initialValue, lastReturnedPropertyValue)
    }

    func ensureEventDeallocated<C, T where C: NSObject>(createControl: () -> C, _ eventSelector: C -> ControlEvent<T>) {
        return ensureEventDeallocated({ () -> (C, Disposable) in (createControl(), NopDisposable.instance) }, eventSelector)
    }

    func ensureEventDeallocated<C, T where C: NSObject>(createControl: () -> (C, Disposable), _ eventSelector: C -> ControlEvent<T>) {
        var completed = false
        var deallocated = false

        autoreleasepool {
            let (control, disposable) = createControl()
            let eventObservable = eventSelector(control)

            _ = eventObservable.subscribe(onNext: { n in

            }, onCompleted: {
                completed = true
            })

            _ = control.rx_deallocated.subscribeNext { _ in
                deallocated = true
            }

            disposable.dispose()
        }


        XCTAssertTrue(deallocated)
        XCTAssertTrue(completed)
    }
}
