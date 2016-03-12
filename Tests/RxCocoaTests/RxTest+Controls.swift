//
//  RxTest+Controls.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import XCTest

extension RxTest {
    func ensurePropertyDeallocated<C, T: Equatable where C: NSObject>(createControl: () -> C, _ initialValue: T, _ propertySelector: C -> ControlProperty<T>) {
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


            _ = control.rx_deallocated.subscribeNext { _ in
                deallocated = true
            }

            control = nil
        }


        // this code is here to flush any events that were scheduled to
        // run on main loop
        dispatch_async(dispatch_get_main_queue()) {
            let runLoop = CFRunLoopGetCurrent()
            CFRunLoopStop(runLoop)
        }
        let runLoop = CFRunLoopGetCurrent()
        CFRunLoopWakeUp(runLoop)
        CFRunLoopRun()

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
        let outerDisposable = SingleAssignmentDisposable()

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

            outerDisposable.disposable = disposable
        }

        outerDisposable.dispose()
        XCTAssertTrue(deallocated)
        XCTAssertTrue(completed)
    }

    func ensureControlObserverHasWeakReference<C, T where C: NSObject>(@autoclosure createControl: () -> (C), _ observerSelector: C -> AnyObserver<T>, _ observableSelector: () -> (Observable<T>)) {
        var deallocated = false

        let disposeBag = DisposeBag()

        autoreleasepool {
            let control = createControl()
            let propertyObserver = observerSelector(control)
            let observable = observableSelector()

            observable.bindTo(propertyObserver).addDisposableTo(disposeBag)

            _ = control.rx_deallocated.subscribeNext { _ in
                deallocated = true
            }
        }

        XCTAssertTrue(deallocated)
    }
}