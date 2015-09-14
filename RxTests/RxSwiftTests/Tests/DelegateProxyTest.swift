//
//  DelegateProxyTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 7/5/15.
//
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
#if os(iOS)
import UIKit
#endif

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
        get {
            return proxyForObject(self) as ThreeDSectionedViewDelegateProxy
        }
    }
}
//

// mock {

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

// }

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
        
        let d = view.rx_proxy.observe("threeDView:didLearnSomething:")
            .subscribeNext { n in
                observedFeedRequest = true
            }
            .scopedDispose()

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
        
        var d = view.rx_proxy.observe("threeDView:didLearnSomething:")
            .subscribeNext { n in
                nMessages++
            }
            .scopedDispose()
        
        XCTAssertTrue(nMessages == 0)
        view.delegate?.threeDView?(view, didLearnSomething: "Psssst ...")
        XCTAssertTrue(nMessages == 1)
        
        d = NopDisposable.instance.scopedDispose()

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
       
        XCTAssertTrue(!mock.respondsToSelector("threeDView(threeDView:didGetXXX:"))
        
        let sentArgument = NSIndexPath(index: 0)
        
        var receivedArgument: NSIndexPath? = nil
        
        let d = view.rx_proxy.observe("threeDView:didGetXXX:")
            .subscribeNext { n in
                let ip = n[1] as! NSIndexPath
                receivedArgument = ip
            }
            .scopedDispose

        XCTAssertTrue(receivedArgument === nil)
        view.delegate?.threeDView?(view, didGetXXX: sentArgument)
        XCTAssertTrue(receivedArgument === sentArgument)
        
        XCTAssertEqual(mock.messages, [])
    }
    
    func test_delegateProxyCompletesOnDealloc() {
        var view: ThreeDSectionedView! = ThreeDSectionedView()
        let mock = MockThreeDSectionedViewProtocol()
        
        view.delegate = mock
        
        let completed = RxMutableBox(false)
        
        autoreleasepool {
            XCTAssertTrue(!mock.respondsToSelector("threeDView(threeDView:didGetXXX:"))
            
            let sentArgument = NSIndexPath(index: 0)
            
            var receivedArgument: NSIndexPath? = nil
            
            view.rx_proxy.observe("threeDView:didGetXXX:")
                .subscribeCompleted {
                    completed.value = true
                }
            
            view.delegate?.threeDView?(view, didGetXXX: sentArgument)
        }
        XCTAssertTrue(!completed.value)
        view = nil
        XCTAssertTrue(completed.value)
    }
}