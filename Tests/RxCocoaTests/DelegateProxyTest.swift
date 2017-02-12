//
//  DelegateProxyTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
#if os(iOS)
import UIKit
#endif

// MARK: Protocols

@objc protocol TestDelegateProtocol {
    @objc optional func testEventHappened(_ value: Int)
}

@objc class MockTestDelegateProtocol
    : NSObject
    , TestDelegateProtocol
{
    var numbers = [Int]()

    func testEventHappened(_ value: Int) {
        numbers.append(value)
    }
}

protocol TestDelegateControl: NSObjectProtocol {
    func doThatTest(_ value: Int)

    var delegateProxy: DelegateProxy { get }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable
}

extension TestDelegateControl {

    var testSentMessage: Observable<Int> {
        return delegateProxy
            .sentMessage(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).intValue }
    }

    var testMethodInvoked: Observable<Int> {
        return delegateProxy
            .methodInvoked(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).intValue }
    }
}

// MARK: Tests

final class DelegateProxyTest : RxTest {
    func test_OnInstallDelegateIsRetained() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        let _ = view.rx.proxy

        XCTAssertEqual(mock.messages, [])
        XCTAssertTrue(view.rx.proxy.forwardToDelegate() === mock)
    }
    
    func test_forwardsUnobservedMethods() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        let _ = view.rx.proxy

        var invoked = false

        mock.invoked = {
            invoked = true
        }

        XCTAssertFalse(invoked)
        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        XCTAssertTrue(invoked)
        
        XCTAssertEqual(mock.messages, ["didLearnSomething"])
    }
    
    func test_forwardsObservedMethods() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        var observedFeedRequestSentMessage = false
        var observedMessageInvoked = false
        var events: [MessageProcessingStage] = []

        var delegates: [NSObject?] = []
        var responds: [Bool] = []

        _ = view.rx.observeWeakly(NSObject.self, "delegate").skip(1).subscribe(onNext: { delegate in
            delegates.append(delegate)
            if let delegate = delegate {
                responds.append(delegate.responds(to: #selector(ThreeDSectionedViewProtocol.threeDView(_:didLearnSomething:))))
            }
        })

        let sentMessage = view.rx.proxy.sentMessage(#selector(ThreeDSectionedViewProtocol.threeDView(_:didLearnSomething:)))
        let methodInvoked = view.rx.proxy.methodInvoked(#selector(ThreeDSectionedViewProtocol.threeDView(_:didLearnSomething:)))

        XCTAssertArraysEqual(delegates, [view.rx.proxy]) { $0 === $1 }
        XCTAssertEqual(responds, [true])

        _ = methodInvoked
            .subscribe(onNext: { n in
                observedMessageInvoked = true
                events.append(.methodInvoked)
            })

        XCTAssertArraysEqual(delegates, [view.rx.proxy, nil, view.rx.proxy]) { $0 === $1 }
        XCTAssertEqual(responds, [true, true])

        mock.invoked = {
            events.append(.invoking)
        }
        
        _ = sentMessage
            .subscribe(onNext: { n in
                observedFeedRequestSentMessage = true
                events.append(.sentMessage)
            })

        XCTAssertArraysEqual(delegates, [view.rx.proxy, nil, view.rx.proxy, nil, view.rx.proxy]) { $0 === $1 }
        XCTAssertEqual(responds, [true, true, true])

        XCTAssertTrue(!observedFeedRequestSentMessage)
        XCTAssertTrue(!observedMessageInvoked)
        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        XCTAssertTrue(observedFeedRequestSentMessage)
        XCTAssertTrue(observedMessageInvoked)
        
        XCTAssertEqual(mock.messages, ["didLearnSomething"])
        XCTAssertEqual(events, [.sentMessage, .invoking, .methodInvoked])
    }
    
    func test_forwardsObserverDispose() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        var nMessages = 0
        var invoked = false
        
        let d = view.rx.proxy.sentMessage(#selector(ThreeDSectionedViewProtocol.threeDView(_:didLearnSomething:)))
            .subscribe(onNext: { n in
                nMessages += 1
            })

        let d2 = view.rx.proxy.methodInvoked(#selector(ThreeDSectionedViewProtocol.threeDView(_:didLearnSomething:)))
            .subscribe(onNext: { n in
                nMessages += 1
            })

        mock.invoked = { invoked = true }
        
        XCTAssertTrue(nMessages == 0)
        XCTAssertFalse(invoked)
        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        XCTAssertTrue(invoked)
        XCTAssertTrue(nMessages == 2)

        d.dispose()
        d2.dispose()

        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        XCTAssertTrue(nMessages == 2)
    }
    
    func test_forwardsUnobservableMethods() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock

        var invoked = false
        mock.invoked = { invoked = true }

        XCTAssertFalse(invoked)
        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        XCTAssertTrue(invoked)
        
        XCTAssertEqual(mock.messages, ["didLearnSomething"])
    }
    
    func test_observesUnimplementedOptionalMethods() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
       
        XCTAssertTrue(!mock.responds(to: NSSelectorFromString("threeDView(threeDView:didGetXXX:")))
        
        let sentArgument = IndexPath(index: 0)
        
        var receivedArgumentSentMessage: IndexPath? = nil
        var receivedArgumentMethodInvoked: IndexPath? = nil

        var events: [MessageProcessingStage] = []

        var delegates: [NSObject?] = []
        var responds: [Bool] = []

        _ = view.rx.observeWeakly(NSObject.self, "delegate").skip(1).subscribe(onNext: { delegate in
            delegates.append(delegate)
            if let delegate = delegate {
                responds.append(delegate.responds(to: #selector(ThreeDSectionedViewProtocol.threeDView(_:didGetXXX:))))
            }
        })

        let sentMessage = view.rx.proxy.sentMessage(#selector(ThreeDSectionedViewProtocol.threeDView(_:didGetXXX:)))
        let methodInvoked = view.rx.proxy.methodInvoked(#selector(ThreeDSectionedViewProtocol.threeDView(_:didGetXXX:)))

        XCTAssertArraysEqual(delegates, [view.rx.proxy]) { $0 == $1 }
        XCTAssertEqual(responds, [false])
        
        let d1 = sentMessage
            .subscribe(onNext: { n in
                let ip = n[1] as! IndexPath
                receivedArgumentSentMessage = ip
                events.append(.sentMessage)
            })

        XCTAssertArraysEqual(delegates, [view.rx.proxy, nil, view.rx.proxy]) { $0 == $1 }
        XCTAssertEqual(responds, [false, true])

        let d2 = methodInvoked
            .subscribe(onNext: { n in
                let ip = n[1] as! IndexPath
                receivedArgumentMethodInvoked = ip
                events.append(.methodInvoked)
            })

        XCTAssertArraysEqual(delegates, [view.rx.proxy, nil, view.rx.proxy, nil, view.rx.proxy]) { $0 === $1 }
        XCTAssertEqual(responds, [false, true, true])

        mock.invoked = {
            events.append(.invoking)
        }

        view.delegate?.threeDView?(view, didGetXXX: sentArgument)
        XCTAssertTrue(receivedArgumentSentMessage == sentArgument)
        XCTAssertTrue(receivedArgumentMethodInvoked == sentArgument)
        
        XCTAssertEqual(mock.messages, [])
        XCTAssertEqual(events, [.sentMessage, .methodInvoked])

        d1.dispose()

        XCTAssertArraysEqual(delegates, [view.rx.proxy, nil, view.rx.proxy, nil, view.rx.proxy, nil, view.rx.proxy]) { $0 === $1 }
        XCTAssertEqual(responds, [false, true, true, true])

        d2.dispose()

        XCTAssertArraysEqual(delegates, [view.rx.proxy, nil, view.rx.proxy, nil, view.rx.proxy, nil, view.rx.proxy, nil, view.rx.proxy]) { $0 === $1 }
        XCTAssertEqual(responds, [false, true, true, true, false])
    }
    
    func test_delegateProxyCompletesOnDealloc() {
        var view: ThreeDSectionedView! = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        var completedSentMessage = false
        var completedMethodInvoked = false

        autoreleasepool {
            XCTAssertTrue(!mock.responds(to: NSSelectorFromString("threeDView:threeDView:didGetXXX:")))
            
            let sentArgument = IndexPath(index: 0)
            
            _ = view
                .rx.proxy
                .sentMessage(#selector(ThreeDSectionedViewProtocol.threeDView(_:didGetXXX:)))
                .subscribe(onCompleted: {
                    completedSentMessage = true
                })
            _ = view
                .rx.proxy
                .methodInvoked(#selector(ThreeDSectionedViewProtocol.threeDView(_:didGetXXX:)))
                .subscribe(onCompleted: {
                    completedMethodInvoked = true
                })

            mock.invoked = {}
            
            view.delegate?.threeDView?(view, didGetXXX: sentArgument)
        }
        XCTAssertTrue(!completedSentMessage)
        XCTAssertTrue(!completedMethodInvoked)
        view = nil
        XCTAssertTrue(completedSentMessage)
        XCTAssertTrue(completedMethodInvoked)
    }
}

#if os(iOS)
extension DelegateProxyTest {
    func test_DelegateProxyHierarchyWorks() {
        let tableView = UITableView()
        _ = tableView.rx.delegate.sentMessage(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))
        _ = tableView.rx.delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))
    }
}
#endif

// MARK: Testing extensions

extension DelegateProxyTest {
    func performDelegateTest<Control: TestDelegateControl>( _ createControl: @autoclosure() -> Control) {
        var control: TestDelegateControl!

        autoreleasepool {
            control = createControl()
        }

        var receivedValueSentMessage: Int!
        var receivedValueMethodInvoked: Int!
        var completedSentMessage = false
        var completedMethodInvoked = false
        var deallocated = false
        var stages: [MessageProcessingStage] = []

        autoreleasepool {
            _ = control.testSentMessage.subscribe(onNext: { value in
                receivedValueSentMessage = value
                stages.append(.sentMessage)
            }, onCompleted: {
                completedSentMessage = true
            })

            _ = control.testMethodInvoked.subscribe(onNext: { value in
                receivedValueMethodInvoked = value
                stages.append(.methodInvoked)
            }, onCompleted: {
                completedMethodInvoked = true
            })

            _ = (control as! NSObject).rx.deallocated.subscribe(onNext: { _ in
                deallocated = true
            })
        }

        XCTAssertTrue(receivedValueSentMessage == nil)
        XCTAssertTrue(receivedValueMethodInvoked == nil)
        XCTAssertEqual(stages, [])
        autoreleasepool {
            control.doThatTest(382763)
        }
        XCTAssertEqual(stages, [.sentMessage, .methodInvoked])
        XCTAssertEqual(receivedValueSentMessage, 382763)
        XCTAssertEqual(receivedValueMethodInvoked, 382763)

        autoreleasepool {
            let mine = MockTestDelegateProtocol()
            let disposable = control.setMineForwardDelegate(mine)

            XCTAssertEqual(mine.numbers, [])
            control.doThatTest(2)
            XCTAssertEqual(mine.numbers, [2])
            disposable.dispose()
            control.doThatTest(3)
            XCTAssertEqual(mine.numbers, [2])
        }

        XCTAssertFalse(deallocated)
        XCTAssertFalse(completedSentMessage)
        XCTAssertFalse(completedMethodInvoked)
        autoreleasepool {
            control = nil
        }
        XCTAssertTrue(deallocated)
        XCTAssertTrue(completedSentMessage)
        XCTAssertTrue(completedMethodInvoked)
    }
}

// MARK: Mocks

// test case {

final class Food: NSObject {
}

@objc protocol ThreeDSectionedViewProtocol {
    func threeDView(_ threeDView: ThreeDSectionedView, listenToMeee: IndexPath)
    func threeDView(_ threeDView: ThreeDSectionedView, feedMe: IndexPath)
    func threeDView(_ threeDView: ThreeDSectionedView, howTallAmI: IndexPath) -> CGFloat
    
    @objc optional func threeDView(_ threeDView: ThreeDSectionedView, didGetXXX: IndexPath)
    @objc optional func threeDView(_ threeDView: ThreeDSectionedView, didLearnSomething: String)
    @objc optional func threeDView(_ threeDView: ThreeDSectionedView, didFallAsleep: IndexPath)
    @objc optional func threeDView(_ threeDView: ThreeDSectionedView, getMeSomeFood: IndexPath) -> Food
}

final class ThreeDSectionedView: NSObject {
    dynamic var delegate: ThreeDSectionedViewProtocol?
}

// }

// integration {

final class ThreeDSectionedViewDelegateProxy : DelegateProxy
                                       , ThreeDSectionedViewProtocol
                                       , DelegateProxyType {
    required init(parentObject: AnyObject) {
        super.init(parentObject: parentObject)
    }
    
    // delegate
    
    func threeDView(_ threeDView: ThreeDSectionedView, listenToMeee: IndexPath) {
        
    }
    
    func threeDView(_ threeDView: ThreeDSectionedView, feedMe: IndexPath) {
        
    }
    
    func threeDView(_ threeDView: ThreeDSectionedView, howTallAmI: IndexPath) -> CGFloat {
        return 1.1
    }
    
    // integration
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let view = object as! ThreeDSectionedView
        view.delegate = delegate as? ThreeDSectionedViewProtocol
    }
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let view = object as! ThreeDSectionedView
        return view.delegate
    }
}

extension Reactive where Base: ThreeDSectionedView {
    var proxy: DelegateProxy {
        return ThreeDSectionedViewDelegateProxy.proxyForObject(base)
    }
}

// }

final class MockThreeDSectionedViewProtocol : NSObject, ThreeDSectionedViewProtocol {
    
    var messages: [String] = []
    var invoked: (() -> ())!

    func threeDView(_ threeDView: ThreeDSectionedView, listenToMeee: IndexPath) {
        messages.append("listenToMeee")
        invoked()
    }
    
    func threeDView(_ threeDView: ThreeDSectionedView, feedMe: IndexPath) {
        messages.append("feedMe")
        invoked()
    }
    
    func threeDView(_ threeDView: ThreeDSectionedView, howTallAmI: IndexPath) -> CGFloat {
        messages.append("howTallAmI")
        invoked()
        return 3
    }
    
    /*func threeDView(threeDView: ThreeDSectionedView, didGetXXX: IndexPath) {
        messages.append("didGetXXX")
    }*/
    
    func threeDView(_ threeDView: ThreeDSectionedView, didLearnSomething: String) {
        messages.append("didLearnSomething")
        invoked()
    }
    
    //optional func threeDView(threeDView: ThreeDSectionedView, didFallAsleep: IndexPath)
    func threeDView(_ threeDView: ThreeDSectionedView, getMeSomeFood: IndexPath) -> Food {
        messages.append("getMeSomeFood")
        invoked()
        return Food()
    }
}

#if os(macOS)
extension MockTestDelegateProtocol
    : NSTextFieldDelegate {

    }
#endif

#if os(iOS) || os(tvOS)
extension MockTestDelegateProtocol
    : UICollectionViewDataSource
    , UIScrollViewDelegate
    , UITableViewDataSource
    , UITableViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError()
    }
}
#endif
