//
//  KVOObservableTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 5/19/15.
//
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

class KVOObservableTests : RxTest {
}

class TestClass : NSObject {
    dynamic var pr: String? = "0"
}

class Parent : NSObject {
    var disposeBag: DisposeBag! = DisposeBag()

    dynamic var val: String = ""
    
    init(callback: String? -> Void) {
        super.init()
        
        self.rx_observe("val", options: NSKeyValueObservingOptions.Initial.union(.New), retainSelf: false)
            .subscribeNext(callback)
            .addDisposableTo(disposeBag)
    }
    
    deinit {
        disposeBag = nil
    }
}

class Child : NSObject {
    let disposeBag = DisposeBag()
    
    init(parent: ParentWithChild, callback: String? -> Void) {
        super.init()
        parent.rx_observe("val", options: NSKeyValueObservingOptions.Initial.union(.New), retainSelf: false)
            .subscribeNext(callback)
            .addDisposableTo(disposeBag)
    }
    
    deinit {
        
    }
}

class ParentWithChild : NSObject {
    dynamic var val: String = ""
    
    var child: Child? = nil
    
    init(callback: String? -> Void) {
        super.init()
        child = Child(parent: self, callback: callback)
    }
}

class HasStrongProperty : NSObject {
    dynamic var property: NSObject? = nil
    dynamic var frame: CGRect
    dynamic var point: CGPoint
    dynamic var size: CGSize

    dynamic var integer: Int
    
    override init() {
        self.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.point = CGPoint(x: 3, y: 5)
        self.size = CGSizeMake(1, 2)
        
        self.integer = 1
        super.init()
    }
}

class HasWeakProperty : NSObject {
    dynamic weak var property: NSObject? = nil
    
    override init() {
        super.init()
    }
}

// test fast observe


extension KVOObservableTests {
    func test_New() {
        let testClass = TestClass()
        
        let os: Observable<String?> = testClass.rx_observe("pr", options: .New)
        
        var latest: String?
        
        var _d: ScopedDisposable? = os .subscribeNext { latest = $0 }.scopedDispose()
        
        XCTAssertTrue(latest == nil)
        
        testClass.pr = "1"
        
        XCTAssertEqual(latest!, "1")
        
        testClass.pr = "2"
        
        XCTAssertEqual(latest!, "2")

        testClass.pr = nil
        
        XCTAssertTrue(latest == nil)

        testClass.pr = "3"
        
        XCTAssertEqual(latest!, "3")
        
        _d = nil
        
        testClass.pr = "4"

        XCTAssertEqual(latest!, "3")
    }
    
    func test_New_And_Initial() {
        let testClass = TestClass()
        
        let os: Observable<String?> = testClass.rx_observe("pr", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.Initial.rawValue | NSKeyValueObservingOptions.New.rawValue))
        
        var latest: String?
        
        var _d: ScopedDisposable? = os .subscribeNext { latest = $0 }.scopedDispose()
        
        XCTAssertTrue(latest == "0")
        
        testClass.pr = "1"
        
        XCTAssertEqual(latest ?? "", "1")
        
        testClass.pr = "2"
        
        XCTAssertEqual(latest ?? "", "2")
        
        testClass.pr = nil
        
        XCTAssertTrue(latest == nil)
        
        testClass.pr = "3"
        
        XCTAssertEqual(latest ?? "", "3")
        
        _d = nil
        
        testClass.pr = "4"
        
        XCTAssertEqual(latest ?? "", "3")
    }
    
    func test_Default() {
        let testClass = TestClass()
        
        let os: Observable<String?> = testClass.rx_observe("pr")
        
        var latest: String?
        
        var _d: ScopedDisposable! = os .subscribeNext { latest = $0 }.scopedDispose()
        
        XCTAssertTrue(latest == "0")
        
        testClass.pr = "1"
        
        XCTAssertEqual(latest!, "1")
        
        testClass.pr = "2"
        
        XCTAssertEqual(latest!, "2")
        
        testClass.pr = nil
        
        XCTAssertTrue(latest == nil)
        
        testClass.pr = "3"
        
        XCTAssertEqual(latest!, "3")
        
        _d = nil
        
        testClass.pr = "4"
        
        XCTAssertEqual(latest!, "3")
    }
    
    func test_ObserveAndDontRetainWorks() {
        var latest: String?
        var disposed = false
        
        var parent: Parent! = Parent { n in
            latest = n
        }
        
        parent.rx_deallocated
            .subscribeCompleted {
                disposed = true
            }
        
        XCTAssertTrue(latest == "")
        XCTAssertTrue(disposed == false)
        
        parent.val = "1"
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == false)
        
        parent = nil
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == true)
    }
    
    func test_ObserveAndDontRetainWorks2() {
        var latest: String?
        var disposed = false
        
        var parent: ParentWithChild! = ParentWithChild { n in
            latest = n
        }
        
        parent.rx_deallocated
            .subscribeCompleted {
                disposed = true
        }
        
        XCTAssertTrue(latest == "")
        XCTAssertTrue(disposed == false)
        
        parent.val = "1"
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == false)
        
        parent = nil
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == true)
    }
}

#if !DISABLE_SWIZZLING
// test weak observe 

extension KVOObservableTests {
    
    func testObserveWeak_SimpleStrongProperty() {
        var latest: String?
        var disposed = false
        
        var root: HasStrongProperty! = HasStrongProperty()
        
        root.rx_observeWeakly("property")
            .subscribeNext { (n: String?) in
                latest = n
            }
        
        root.rx_deallocated
            .subscribeCompleted {
                disposed = true
            }
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(!disposed)
        
        root.property = "a"

        XCTAssertTrue(latest == "a")
        XCTAssertTrue(!disposed)
        
        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed)
    }
    
    func testObserveWeak_SimpleWeakProperty() {
        var latest: String?
        var disposed = false
        
        var root: HasWeakProperty! = HasWeakProperty()
        
        root.rx_observeWeakly("property")
            .subscribeNext { (n: String?) in
                latest = n
        }
        
        root.rx_deallocated
            .subscribeCompleted {
                disposed = true
        }
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(!disposed)
    
        var a: NSString! = "a"
        
        root.property = a
        
        XCTAssertTrue(latest == "a")
        XCTAssertTrue(!disposed)
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed)
    }

    func testObserveWeak_ObserveFirst_Weak_Strong_Basic() {
        var latest: String?
        var disposed = false
        
        var child: HasStrongProperty! = HasStrongProperty()
        
        var root: HasWeakProperty! = HasWeakProperty()
        
        root.rx_observeWeakly("property.property")
            .subscribeNext { (n: String?) in
                latest = n
            }
        
        root.rx_deallocated
            .subscribeCompleted {
                disposed = true
            }
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        root.property = child
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        var one: NSString! = "1"
        
        child.property = one
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == false)
        
        root = nil
        child = nil
     
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == true)
    }
    
    func testObserveWeak_Weak_Strong_Observe_Basic() {
        var latest: String?
        var disposed = false
        
        var child: HasStrongProperty! = HasStrongProperty()
        
        var root: HasWeakProperty! = HasWeakProperty()
        
        root.property = child
        
        var one: NSString! = "1"
        
        child.property = one
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        root.rx_observeWeakly("property.property")
            .subscribeNext { (n: String?) in
                latest = n
        }
        
        root.rx_deallocated
            .subscribeCompleted {
                disposed = true
        }
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == false)
        
        root = nil
        child = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == true)
    }
    
    func testObserveWeak_ObserveFirst_Strong_Weak_Basic() {
        var latest: String?
        var disposed = false
        
        var child: HasWeakProperty! = HasWeakProperty()
        
        var root: HasStrongProperty! = HasStrongProperty()
        
        root.rx_observeWeakly("property.property")
            .subscribeNext { (n: String?) in
                latest = n
        }
        
        root.rx_deallocated
            .subscribeCompleted {
                disposed = true
        }
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        root.property = child
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        var one: NSString! = "1"
        
        child.property = one
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == false)
        
        root = nil
        child = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == true)
    }
    
    func testObserveWeak_Strong_Weak_Observe_Basic() {
        var latest: String?
        var disposed = false
        
        var child: HasWeakProperty! = HasWeakProperty()
        
        var root: HasStrongProperty! = HasStrongProperty()
        
        root.property = child
        
        var one: NSString! = "1"
        
        child.property = one
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        root.rx_observeWeakly("property.property")
            .subscribeNext { (n: String?) in
                latest = n
            }
        
        root.rx_deallocated
            .subscribeCompleted {
                disposed = true
        }
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == false)
        
        root = nil
        child = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == true)
    }
    
    // compiler won't release weak references otherwise :(
    func _testObserveWeak_Strong_Weak_Observe_NilLastPropertyBecauseOfWeak() -> (HasWeakProperty, RxMutableBox<NSObject?>, Observable<Void>) {
        var dealloc: Observable<Void>! = nil
        var child: HasWeakProperty! = HasWeakProperty()
        var latest: RxMutableBox<NSObject?>! = RxMutableBox(nil)
        
        autoreleasepool {
            var root: HasStrongProperty! = HasStrongProperty()
            
            root.property = child
            
            var one: NSObject! = nil
            
            one = NSObject()
            
            child.property = one
            
            XCTAssertTrue(latest.value == nil)
            
            let observable: Observable<NSObject?> = root.rx_observeWeakly("property.property")
            observable .subscribeNext { n in
                latest?.value = n
            }
            
            XCTAssertTrue(latest.value! === one)
         
            dealloc = one.rx_deallocating
            
            one = nil
        }
        return (child, latest, dealloc)
    }
    
    func testObserveWeak_Strong_Weak_Observe_NilLastPropertyBecauseOfWeak() {
        var gone = false
        let (child, latest, dealloc) = _testObserveWeak_Strong_Weak_Observe_NilLastPropertyBecauseOfWeak()
        dealloc
            .subscribeNext { n in
                gone = true
            }
        
        XCTAssertTrue(gone)
        XCTAssertTrue(child.property == nil)
        XCTAssertTrue(latest.value == nil)
    }
    
    func _testObserveWeak_Weak_Weak_Weak_middle_NilifyCorrectly() -> (HasWeakProperty, RxMutableBox<NSObject?>, Observable<Void>) {
        var dealloc: Observable<Void>! = nil
        var middle: HasWeakProperty! = HasWeakProperty()
        var latest: RxMutableBox<NSObject?>! = RxMutableBox(nil)
        var root: HasWeakProperty! = HasWeakProperty()
        
        autoreleasepool {
            middle = HasWeakProperty()
            var leaf = HasWeakProperty()
            
            root.property = middle
            middle.property = leaf
            
            XCTAssertTrue(latest.value == nil)
            
            let observable: Observable<NSObject?> = root.rx_observeWeakly("property.property.property")
            observable .subscribeNext { n in
                latest?.value = n
            }
            
            XCTAssertTrue(latest.value == nil)
            
            let one = NSObject()
            
            leaf.property = one
            
            XCTAssertTrue(latest.value === one)
            
            dealloc = middle.rx_deallocating
        }
        return (root!, latest, dealloc)
    }
    
    func testObserveWeak_Weak_Weak_Weak_middle_NilifyCorrectly() {
        let (root, latest, deallocatedMiddle) = _testObserveWeak_Weak_Weak_Weak_middle_NilifyCorrectly()
        
        var gone = false
        
        deallocatedMiddle
            .subscribeCompleted {
                gone = true
            }
        
        XCTAssertTrue(gone)
        XCTAssertTrue(root.property == nil)
        XCTAssertTrue(latest.value == nil)
    }
    
    func testObserveWeak_TargetDeallocated() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<String?>(nil)
        
        root.property = "a"
        
        XCTAssertTrue(latest.value == nil)
        
        root.rx_observeWeakly("property")
            .subscribeNext { (n: String?) in
                latest.value = n
            }
       
        XCTAssertTrue(latest.value == "a")
     
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest.value == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeakWithOptions_ObserveNotInitialValue() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<String?>(nil)
        
        root.property = "a"
        
        XCTAssertTrue(latest.value == nil)
        
        root.rx_observeWeakly("property", options: .New)
            .subscribeNext { (n: String?) in
                latest.value = n
        }
        
        XCTAssertTrue(latest.value == nil)
        
        root.property = "b"

        XCTAssertTrue(latest.value == "b")
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }
        
        root = nil
        
        XCTAssertTrue(latest.value == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    #if os(OSX)
    // just making sure it's all the same for NS extensions
    func testObserve_ObserveNSRect() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<NSRect?>(nil)
        
        XCTAssertTrue(latest.value == nil)
        
        let disposable = root.rx_observe("frame")
            .subscribeNext { (n: NSRect?) in
                latest.value = n
            }
        XCTAssertTrue(latest.value == root.frame)
        
        root.frame = NSRect(x: -2, y: 0, width: 0, height: 1)
        
        XCTAssertTrue(latest.value == NSRect(x: -2, y: 0, width: 0, height: 1))
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest.value == NSRect(x: -2, y: 0, width: 0, height: 1))
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }
    #endif

    
    // let's just check for one, otherones should have the same check
    func testObserve_ObserveCGRectForBiggerStructureDoesntCrashPropertyTypeReturnsNil() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<CGSize?>(nil)
        
        XCTAssertTrue(latest.value == nil)
        
        let d = root.rx_observe("frame")
            .subscribeNext { (n: CGSize?) in
                latest.value = n
            }
            .scopedDispose()
        XCTAssertTrue(latest.value == nil)
        
        root.size = CGSizeMake(56, 1)
        
        XCTAssertTrue(latest.value == nil)
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }
        
        root = nil
        
        XCTAssertTrue(latest.value == nil)
        XCTAssertTrue(!rootDeallocated)
    }
    
    func testObserve_ObserveCGRect() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<CGRect?>(nil)
        
        XCTAssertTrue(latest.value == nil)
        
        let d = root.rx_observe("frame")
            .subscribeNext { (n: CGRect?) in
                latest.value = n
            }
            .scopedDispose()
        XCTAssertTrue(latest.value == root.frame)
        
        root.frame = CGRectMake(-2, 0, 0, 1)
        
        XCTAssertTrue(latest.value == CGRectMake(-2, 0, 0, 1))
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest.value == CGRectMake(-2, 0, 0, 1))
        XCTAssertTrue(!rootDeallocated)
    }
    
    func testObserve_ObserveCGSize() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<CGSize?>(nil)
        
        XCTAssertTrue(latest.value == nil)
        
        let d = root.rx_observe("size")
            .subscribeNext { (n: CGSize?) in
                latest.value = n
            }
            .scopedDispose()
        XCTAssertTrue(latest.value == root.size)
        
        root.size = CGSizeMake(56, 1)
        
        XCTAssertTrue(latest.value == CGSizeMake(56, 1))
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest.value == CGSizeMake(56, 1))
        XCTAssertTrue(!rootDeallocated)
    }
    
    func testObserve_ObserveCGPoint() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<CGPoint?>(nil)
        
        XCTAssertTrue(latest.value == nil)
        
        let d = root.rx_observe("point")
            .subscribeNext { (n: CGPoint?) in
                latest.value = n
            }
            .scopedDispose()
        
        XCTAssertTrue(latest.value == root.point)
        
        root.point = CGPoint(x: -100, y: 1)
        
        XCTAssertTrue(latest.value == CGPoint(x: -100, y: 1))
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest.value == CGPoint(x: -100, y: 1))
        XCTAssertTrue(!rootDeallocated)
    }
    
    
    func testObserveWeak_ObserveCGRect() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<CGRect?>(nil)
        
        XCTAssertTrue(latest.value == nil)
        
        root.rx_observeWeakly("frame")
            .subscribeNext { (n: CGRect?) in
                latest.value = n
            }
        XCTAssertTrue(latest.value == root.frame)
        
        root.frame = CGRectMake(-2, 0, 0, 1)
        
        XCTAssertTrue(latest.value == CGRectMake(-2, 0, 0, 1))
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest.value == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_ObserveCGSize() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<CGSize?>(nil)
        
        XCTAssertTrue(latest.value == nil)
        
        root.rx_observeWeakly("size")
            .subscribeNext { (n: CGSize?) in
                latest.value = n
            }
        XCTAssertTrue(latest.value == root.size)
        
        root.size = CGSizeMake(56, 1)
        
        XCTAssertTrue(latest.value == CGSizeMake(56, 1))
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }
        
        root = nil
        
        XCTAssertTrue(latest.value == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_ObserveCGPoint() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<CGPoint?>(nil)
        
        XCTAssertTrue(latest.value == nil)
        
        root.rx_observeWeakly("point")
            .subscribeNext { (n: CGPoint?) in
                latest.value = n
            }
        
        XCTAssertTrue(latest.value == root.point)
        
        root.point = CGPoint(x: -100, y: 1)
        
        XCTAssertTrue(latest.value == CGPoint(x: -100, y: 1))
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest.value == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_ObserveInt() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        let latest = RxMutableBox<Int?>(nil)
        
        XCTAssertTrue(latest.value == nil)
        
        root.rx_observeWeakly("integer")
            .subscribeNext { (n: NSNumber?) in
                latest.value = n?.integerValue
            }
        XCTAssertTrue(latest.value == root.integer)
        
        root.integer = 10
        
        XCTAssertTrue(latest.value == 10)
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }
        
        root = nil
        
        XCTAssertTrue(latest.value == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_PropertyDoesntExist() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var lastError: ErrorType? = nil
        
        (root.rx_observeWeakly("notExist") as Observable<NSNumber?>)
            .subscribeError { error in
                lastError = error
            }
        
        XCTAssertTrue(lastError != nil)
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_HierarchyPropertyDoesntExist() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var lastError: ErrorType? = nil
        
        (root.rx_observeWeakly("property.notExist") as Observable<NSNumber?>)
            .subscribeError { error in
                lastError = error
            }
        
        XCTAssertTrue(lastError == nil)
        
        root.property = HasStrongProperty()

        XCTAssertTrue(lastError != nil)
        
        var rootDeallocated = false
        
        root.rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(rootDeallocated)
    }
}
#endif
