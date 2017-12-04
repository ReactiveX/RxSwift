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
    associatedtype TestParentObject: AnyObject
    associatedtype TestDelegate
    func doThatTest(_ value: Int)

    var delegateProxy: DelegateProxy<TestParentObject, TestDelegate> { get }

    func setMineForwardDelegate(_ testDelegate: TestDelegate) -> Disposable
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

extension DelegateProxyTest {
    func test_delegateProxyType() {
        let view = InitialClassView()
        let subclassView = InitialClassViewSubclass()
        _ = InitialClassViewDelegateProxy.createProxy(for: view)
        let proxy2 = InitialClassViewDelegateProxy.createProxy(for: subclassView)
        XCTAssert(proxy2 is InitialClassViewDelegateProxySubclass)
    }
    
    func test_delegateProxyTypeExtend_a() {
        let extendView1 = InitialClassViewSometimeExtended1_a()
        let extendView2 = InitialClassViewSometimeExtended2_a()
        _ = InitialClassViewDelegateProxy.createProxy(for: extendView1)
        _ = InitialClassViewDelegateProxy.createProxy(for: extendView2)

        ExtendClassViewDelegateProxy_a.register { ExtendClassViewDelegateProxy_a(parentObject1: $0) }

        let extendedProxy1 = InitialClassViewDelegateProxy.createProxy(for: extendView1)
        let extendedProxy2 = InitialClassViewDelegateProxy.createProxy(for: extendView2)
        XCTAssert(extendedProxy1 is ExtendClassViewDelegateProxy_a)
        XCTAssert(extendedProxy2 is ExtendClassViewDelegateProxy_a)
    }
    
    func test_delegateProxyTypeExtend_b() {
        let extendView1 = InitialClassViewSometimeExtended1_b()
        let extendView2 = InitialClassViewSometimeExtended2_b()
        _ = InitialClassViewDelegateProxy.createProxy(for: extendView1)
        _ = InitialClassViewDelegateProxy.createProxy(for: extendView2)

        ExtendClassViewDelegateProxy_b.register { ExtendClassViewDelegateProxy_b(parentObject2: $0) }

        _ = InitialClassViewDelegateProxy.createProxy(for: extendView1)
        let extendedProxy2 = InitialClassViewDelegateProxy.createProxy(for: extendView2)
        XCTAssert(extendedProxy2 is ExtendClassViewDelegateProxy_b)
    }
}

extension DelegateProxyTest {
    func test_InstallPureSwiftDelegateProxy() {
        let view = PureSwiftView()
        let mock = MockPureSwiftDelegate()
        
        view.delegate = mock

        let proxy = view.rx.proxy
        XCTAssertTrue(view.delegate === proxy)
        XCTAssertTrue(view.rx.proxy.forwardToDelegate() === mock)

        var latestValue: Int? = nil
        _ = view.rx.testIt.subscribe(onNext: {
            latestValue = $0
        })

        XCTAssertEqual(latestValue, nil)
        view.testIt(with: 3)
        XCTAssertEqual(latestValue, 3)
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
    func performDelegateTest<Control: TestDelegateControl, ExtendedProxy: DelegateProxyType>( _ createControl: @autoclosure() -> Control, make: @escaping (Control) -> ExtendedProxy) {
        ExtendedProxy.register(make: make)
        var control: Control!

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
            let disposable = control.setMineForwardDelegate(mine as! Control.TestDelegate)

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

@objc protocol ThreeDSectionedViewProtocol: NSObjectProtocol {
    func threeDView(_ threeDView: ThreeDSectionedView, listenToMeee: IndexPath)
    func threeDView(_ threeDView: ThreeDSectionedView, feedMe: IndexPath)
    func threeDView(_ threeDView: ThreeDSectionedView, howTallAmI: IndexPath) -> CGFloat
    
    @objc optional func threeDView(_ threeDView: ThreeDSectionedView, didGetXXX: IndexPath)
    @objc optional func threeDView(_ threeDView: ThreeDSectionedView, didLearnSomething: String)
    @objc optional func threeDView(_ threeDView: ThreeDSectionedView, didFallAsleep: IndexPath)
    @objc optional func threeDView(_ threeDView: ThreeDSectionedView, getMeSomeFood: IndexPath) -> Food
}

final class ThreeDSectionedView: NSObject {
    @objc dynamic var delegate: ThreeDSectionedViewProtocol?
}

extension ThreeDSectionedView: HasDelegate {
    typealias Delegate = ThreeDSectionedViewProtocol
}

// }

// integration {

final class ThreeDSectionedViewDelegateProxy: DelegateProxy<ThreeDSectionedView, ThreeDSectionedViewProtocol>
                                       , ThreeDSectionedViewProtocol
                                       , DelegateProxyType {

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { ThreeDSectionedViewDelegateProxy(parentObject: $0) }
    }

    init(parentObject: ThreeDSectionedView) {
        super.init(parentObject: parentObject, delegateProxy: ThreeDSectionedViewDelegateProxy.self)
    }
    
    // delegate
    
    func threeDView(_ threeDView: ThreeDSectionedView, listenToMeee: IndexPath) {
        
    }
    
    func threeDView(_ threeDView: ThreeDSectionedView, feedMe: IndexPath) {
        
    }
    
    func threeDView(_ threeDView: ThreeDSectionedView, howTallAmI: IndexPath) -> CGFloat {
        return 1.1
    }
}

extension Reactive where Base: ThreeDSectionedView {
    var proxy: DelegateProxy<ThreeDSectionedView, ThreeDSectionedViewProtocol> {
        return ThreeDSectionedViewDelegateProxy.proxy(for: base)
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

// test case {

@objc protocol InitialClassViewDelegate: NSObjectProtocol {
    
}

class InitialClassView: NSObject {
    weak var delegate: InitialClassViewDelegate?
}

class InitialClassViewSubclass: InitialClassView {
    
}

class InitialClassViewDelegateProxy
    : DelegateProxy<InitialClassView, InitialClassViewDelegate>
    , DelegateProxyType
    , InitialClassViewDelegate {

    init(parentObject: InitialClassView) {
        super.init(parentObject: parentObject, delegateProxy: InitialClassViewDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { InitialClassViewDelegateProxy(parentObject: $0) }
        self.register { InitialClassViewDelegateProxySubclass(parentObject: $0) }
    }

    static func currentDelegate(for object: ParentObject) -> InitialClassViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: InitialClassViewDelegate?, to object: ParentObject) {
        return object.delegate = delegate
    }
}

class InitialClassViewDelegateProxySubclass: InitialClassViewDelegateProxy {
    init(parentObject: InitialClassViewSubclass) {
        super.init(parentObject: parentObject)
    }
}

class InitialClassViewSometimeExtended1_a: InitialClassView {

}

class InitialClassViewSometimeExtended2_a: InitialClassViewSometimeExtended1_a {
    
}

class InitialClassViewSometimeExtended1_b: InitialClassView {
    
}

class InitialClassViewSometimeExtended2_b: InitialClassViewSometimeExtended1_b {
    
}

class ExtendClassViewDelegateProxy_a: InitialClassViewDelegateProxy {
    init(parentObject1: InitialClassViewSometimeExtended1_a) {
        super.init(parentObject: parentObject1)
    }

    init(parentObject2: InitialClassViewSometimeExtended2_a) {
        super.init(parentObject: parentObject2)
    }
}

class ExtendClassViewDelegateProxy_b: InitialClassViewDelegateProxy {
    init(parentObject1: InitialClassViewSometimeExtended1_b) {
        super.init(parentObject: parentObject1)
    }

    init(parentObject2: InitialClassViewSometimeExtended2_b) {
        super.init(parentObject: parentObject2)
    }
}


protocol PureSwiftDelegate: class {
    func delegateTestIt(with: Int)
}

class PureSwiftView: ReactiveCompatible {
    weak var delegate: PureSwiftDelegate?

    func testIt(with: Int) {
        self.delegate?.delegateTestIt(with: with)
    }
}

extension Reactive where Base: PureSwiftView {
    var proxy: DelegateProxy<PureSwiftView, PureSwiftDelegate> {
        return PureSwiftDelegateProxy.proxy(for: base)
    }
}

extension Reactive where Base: PureSwiftView {
    var testIt: ControlEvent<Int> {
        return ControlEvent(events: PureSwiftDelegateProxy.proxy(for: base).testItObserver)
    }
}

class PureSwiftDelegateProxy
    : DelegateProxy<PureSwiftView, PureSwiftDelegate>
    , DelegateProxyType
    , PureSwiftDelegate {

    fileprivate let testItObserver = PublishSubject<Int>()

    init(parentObject: PureSwiftView) {
        super.init(parentObject: parentObject, delegateProxy: PureSwiftDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { PureSwiftDelegateProxy.init(parentObject: $0) }
    }
    
    static func currentDelegate(for object: ParentObject) -> PureSwiftDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: PureSwiftDelegate?, to object: ParentObject) {
        return object.delegate = delegate
    }

    func delegateTestIt(with: Int) {
        testItObserver.on(.next(with))
        self.forwardToDelegate()?.delegateTestIt(with: with)
    }

    deinit {
        self.testItObserver.on(.completed)
    }
}

final class MockPureSwiftDelegate: PureSwiftDelegate {
    var latestValue: Int?

    func delegateTestIt(with: Int) {
        latestValue = with
    }
}

// }

#if os(macOS)
extension MockTestDelegateProtocol
    : NSTextFieldDelegate {

    }
#endif

#if os(iOS)
extension MockTestDelegateProtocol: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        fatalError()
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        fatalError()
    }
}
#endif

#if os(iOS) || os(tvOS)
extension MockTestDelegateProtocol
    : UICollectionViewDataSource
    , UIScrollViewDelegate
    , UITableViewDataSource
    , UITableViewDelegate
    , UISearchBarDelegate
    , UISearchControllerDelegate
    , UINavigationControllerDelegate
    , UITabBarControllerDelegate
    , UITabBarDelegate
    {

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

#if os(iOS)
extension MockTestDelegateProtocol
    : UIPickerViewDelegate
    , UIWebViewDelegate
{
}
#endif
