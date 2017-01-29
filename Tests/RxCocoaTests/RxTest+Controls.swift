//
//  RxTest+Controls.swift
//  Tests
//
//  Created by Krunoslav Zaher on 3/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import XCTest

extension RxTest {
    func ensurePropertyDeallocated<C, T: Equatable>(_ createControl: () -> C, _ initialValue: T, _ propertySelector: (C) -> ControlProperty<T>) where C: NSObject {

        ensurePropertyDeallocated(createControl, initialValue, comparer: ==, propertySelector)
    }

    func ensurePropertyDeallocated<C, T>(_ createControl: () -> C, _ initialValue: T, comparer: (T, T) -> Bool, _ propertySelector: (C) -> ControlProperty<T>) where C: NSObject  {

        let variable = Variable(initialValue)

        var completed = false
        var deallocated = false
        var lastReturnedPropertyValue: T!

        autoreleasepool {
            var control: C! = createControl()

            let property = propertySelector(control)

            let disposable = variable.asObservable().bindTo(property)

            _ = property.subscribe(onNext: { n in
                lastReturnedPropertyValue = n
            }, onCompleted: {
                completed = true
                disposable.dispose()
            })


            _ = (control as NSObject).rx.deallocated.subscribe(onNext: { _ in
                deallocated = true
            })

            control = nil
        }


        // this code is here to flush any events that were scheduled to
        // run on main loop
        DispatchQueue.main.async {
            let runLoop = CFRunLoopGetCurrent()
            CFRunLoopStop(runLoop)
        }
        let runLoop = CFRunLoopGetCurrent()
        CFRunLoopWakeUp(runLoop)
        CFRunLoopRun()

        XCTAssertTrue(deallocated)
        XCTAssertTrue(completed)
        XCTAssertTrue(comparer(initialValue, lastReturnedPropertyValue))
    }

    func ensureEventDeallocated<C, T>(_ createControl: @escaping () -> C, _ eventSelector: (C) -> ControlEvent<T>) where C: NSObject {
        return ensureEventDeallocated({ () -> (C, Disposable) in (createControl(), Disposables.create()) }, eventSelector)
    }

    func ensureEventDeallocated<C, T>(_ createControl: () -> (C, Disposable), _ eventSelector: (C) -> ControlEvent<T>) where C: NSObject {
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
        XCTAssertTrue(deallocated)
        XCTAssertTrue(completed)
    }

    func ensureControlObserverHasWeakReference<C, T>( _ createControl: @autoclosure() -> (C), _ observerSelector: (C) -> AnyObserver<T>, _ observableSelector: () -> (Observable<T>)) where C: NSObject {
        var deallocated = false

        let disposeBag = DisposeBag()

        autoreleasepool {
            let control = createControl()
            let propertyObserver = observerSelector(control)
            let observable = observableSelector()

            observable.bindTo(propertyObserver).disposed(by: disposeBag)

            _ = (control as NSObject).rx.deallocated.subscribe(onNext: { _ in
                deallocated = true
            })
        }

        XCTAssertTrue(deallocated)
    }
}
