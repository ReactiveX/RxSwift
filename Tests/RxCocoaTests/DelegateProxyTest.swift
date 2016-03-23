//
//  DelegateProxyTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
#if os(iOS)
import UIKit
#endif

// MARK: Protocols

@objc protocol TestDelegateProtocol {
    optional func testEventHappened(value: Int)
}

protocol TestDelegateControl: NSObjectProtocol {
    func doThatTest(value: Int)

    var test: Observable<Int> { get }
}

// MARK: Tests

class DelegateProxyTest : RxTest {
    func test_OnInstallDelegateIsRetained() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        let _ = view.rx_proxy
        
        XCTAssertEqual(mock.messages, [])
        XCTAssertTrue(view.rx_proxy.forwardToDelegate() === mock)
    }
    
    func test_forwardsUnobservedMethods() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        let _ = view.rx_proxy
        
        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        
        XCTAssertEqual(mock.messages, ["didLearnSomething"])
    }
    
    func test_forwardsObservedMethods() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        var observedFeedRequest = false
        
        let d = view.rx_proxy.observe(#selector(ThreeDSectionedViewProtocol.threeDView(_:didLearnSomething:)))
            .subscribeNext { n in
                observedFeedRequest = true
            }
        defer {
            d.dispose()
        }

        XCTAssertTrue(!observedFeedRequest)
        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        XCTAssertTrue(observedFeedRequest)
        
        XCTAssertEqual(mock.messages, ["didLearnSomething"])
    }
    
    func test_forwardsObserverDispose() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        var nMessages = 0
        
        let d = view.rx_proxy.observe(#selector(ThreeDSectionedViewProtocol.threeDView(_:didLearnSomething:)))
            .subscribeNext { n in
                nMessages += 1
            }
        
        XCTAssertTrue(nMessages == 0)
        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        XCTAssertTrue(nMessages == 1)

        d.dispose()

        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        XCTAssertTrue(nMessages == 1)
    }
    
    func test_forwardsUnobservableMethods() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        
        XCTAssertEqual(mock.messages, ["didLearnSomething"])
    }
    
    func test_observesUnimplementedOptionalMethods() {
        let view = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
       
        XCTAssertTrue(!mock.respondsToSelector(NSSelectorFromString("threeDView(threeDView:didGetXXX:")))
        
        let sentArgument = NSIndexPath(index: 0)
        
        var receivedArgument: NSIndexPath? = nil
        
        let d = view.rx_proxy.observe(#selector(ThreeDSectionedViewProtocol.threeDView(_:didGetXXX:)))
            .subscribeNext { n in
                let ip = n[1] as! NSIndexPath
                receivedArgument = ip
            }
        defer {
            d.dispose()
        }

        XCTAssertTrue(receivedArgument === nil)
        view.delegate?.threeDView?(view, didGetXXX: sentArgument)
        XCTAssertTrue(receivedArgument === sentArgument)
        
        XCTAssertEqual(mock.messages, [])
    }
    
    func test_delegateProxyCompletesOnDealloc() {
        var view: ThreeDSectionedView! = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        var completed = false
        
        autoreleasepool {
            XCTAssertTrue(!mock.respondsToSelector(NSSelectorFromString("threeDView:threeDView:didGetXXX:")))
            
            let sentArgument = NSIndexPath(index: 0)
            
            _ = view
                .rx_proxy
                .observe(#selector(ThreeDSectionedViewProtocol.threeDView(_:didGetXXX:)))
                .subscribeCompleted {
                    completed = true
                }
            
            view.delegate?.threeDView?(view, didGetXXX: sentArgument)
        }
        XCTAssertTrue(!completed)
        view = nil
        XCTAssertTrue(completed)
    }
}

#if os(iOS)
extension DelegateProxyTest {
    func test_DelegateProxyHierarchyWorks() {
        let tableView = UITableView()
        _ = tableView.rx_delegate.observe(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))
    }
}
#endif

// MARK: Testing extensions

extension DelegateProxyTest {
    func performDelegateTest<Control: TestDelegateControl>(@autoclosure createControl: () -> Control) {
        var control: TestDelegateControl!

        autoreleasepool {
            control = createControl()
        }

        var receivedValue: Int!
        var completed = false
        var deallocated = false

        autoreleasepool {
            _ = control.test.subscribe(onNext: { value in
                receivedValue = value
            }, onCompleted: {
                completed = true
            })

            _ = (control as! NSObject).rx_deallocated.subscribeNext { _ in
                deallocated = true
            }
        }

        XCTAssertTrue(receivedValue == nil)
        autoreleasepool {
            control.doThatTest(382763)
        }
        XCTAssertEqual(receivedValue, 382763)

        XCTAssertFalse(deallocated)
        XCTAssertFalse(completed)
        autoreleasepool {
            control = nil
        }
        XCTAssertTrue(deallocated)
        XCTAssertTrue(completed)
    }
}

// MARK: Mocks

// test case {

class Food: NSObject {
}

@objc protocol ThreeDSectionedViewProtocol {
    func threeDView(threeDView: ThreeDSectionedView, listenToMeee: NSIndexPath)
    func threeDView(threeDView: ThreeDSectionedView, feedMe: NSIndexPath)
    func threeDView(threeDView: ThreeDSectionedView, howTallAmI: NSIndexPath) -> CGFloat
    
    optional func threeDView(threeDView: ThreeDSectionedView, didGetXXX: NSIndexPath)
    optional func threeDView(threeDView: ThreeDSectionedView, didLearnSomething: String)
    optional func threeDView(threeDView: ThreeDSectionedView, didFallAsleep: NSIndexPath)
    optional func threeDView(threeDView: ThreeDSectionedView, getMeSomeFood: NSIndexPath) -> Food
}

class ThreeDSectionedView: NSObject {
    var delegate: ThreeDSectionedViewProtocol?
}

// }

// integration {

class ThreeDSectionedViewDelegateProxy : DelegateProxy
                                       , ThreeDSectionedViewProtocol
                                       , DelegateProxyType {
    required init(parentObject: AnyObject) {
        super.init(parentObject: parentObject)
    }
    
    // delegate
    
    func threeDView(threeDView: ThreeDSectionedView, listenToMeee: NSIndexPath) {
        
    }
    
    func threeDView(threeDView: ThreeDSectionedView, feedMe: NSIndexPath) {
        
    }
    
    func threeDView(threeDView: ThreeDSectionedView, howTallAmI: NSIndexPath) -> CGFloat {
        return 1.1
    }
    
    // integration
    
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let view = object as! ThreeDSectionedView
        view.delegate = delegate as? ThreeDSectionedViewProtocol
    }
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let view = object as! ThreeDSectionedView
        return view.delegate
    }
}

extension ThreeDSectionedView {
    var rx_proxy: DelegateProxy {
        return proxyForObject(ThreeDSectionedViewDelegateProxy.self, self)
    }
}

// }

class MockThreeDSectionedViewProtocol : NSObject, ThreeDSectionedViewProtocol {
    
    var messages: [String] = []
    
    func threeDView(threeDView: ThreeDSectionedView, listenToMeee: NSIndexPath) {
        messages.append("listenToMeee")
    }
    
    func threeDView(threeDView: ThreeDSectionedView, feedMe: NSIndexPath) {
        messages.append("feedMe")
    }
    
    func threeDView(threeDView: ThreeDSectionedView, howTallAmI: NSIndexPath) -> CGFloat {
        messages.append("howTallAmI")
        return 3
    }
    
    /*func threeDView(threeDView: ThreeDSectionedView, didGetXXX: NSIndexPath) {
        messages.append("didGetXXX")
    }*/
    
    func threeDView(threeDView: ThreeDSectionedView, didLearnSomething: String) {
        messages.append("didLearnSomething")
    }
    
    //optional func threeDView(threeDView: ThreeDSectionedView, didFallAsleep: NSIndexPath)
    func threeDView(threeDView: ThreeDSectionedView, getMeSomeFood: NSIndexPath) -> Food {
        messages.append("getMeSomeFood")
        return Food()
    }
}
