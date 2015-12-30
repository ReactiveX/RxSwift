//
//  KVOObservableTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 5/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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
        
        self.rx_observe(String.self, "val", options: [.Initial, .New], retainSelf: false)
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
        parent.rx_observe(String.self, "val", options: [.Initial, .New], retainSelf: false)
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

@objc enum IntEnum: Int {
    typealias RawValue = Int
    case One
    case Two
}

@objc enum UIntEnum: UInt {
    case One
    case Two
}

@objc enum Int32Enum: Int32 {
    case One
    case Two
}

@objc enum UInt32Enum: UInt32 {
    case One
    case Two
}

@objc enum Int64Enum: Int64 {
    case One
    case Two
}

@objc enum UInt64Enum: UInt64 {
    case One
    case Two
}

class HasStrongProperty : NSObject {
    dynamic var property: NSObject? = nil
    dynamic var frame: CGRect
    dynamic var point: CGPoint
    dynamic var size: CGSize
    dynamic var intEnum: IntEnum = .One
    dynamic var uintEnum: UIntEnum = .One
    dynamic var int32Enum: Int32Enum = .One
    dynamic var uint32Enum: UInt32Enum = .One
    dynamic var int64Enum: Int64Enum = .One
    dynamic var uint64Enum: UInt64Enum = .One

    dynamic var integer: Int
    dynamic var uinteger: UInt
    
    override init() {
        self.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.point = CGPoint(x: 3, y: 5)
        self.size = CGSizeMake(1, 2)
        
        self.integer = 1
        self.uinteger = 1
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
        
        let os = testClass.rx_observe(String.self, "pr", options: .New)
        
        var latest: String?
        
        let d = os .subscribeNext { latest = $0 }
        
        XCTAssertTrue(latest == nil)
        
        testClass.pr = "1"
        
        XCTAssertEqual(latest!, "1")
        
        testClass.pr = "2"
        
        XCTAssertEqual(latest!, "2")

        testClass.pr = nil
        
        XCTAssertTrue(latest == nil)

        testClass.pr = "3"
        
        XCTAssertEqual(latest!, "3")
        
        d.dispose()
        
        testClass.pr = "4"

        XCTAssertEqual(latest!, "3")
    }
    
    func test_New_And_Initial() {
        let testClass = TestClass()
        
        let os = testClass.rx_observe(String.self, "pr", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.Initial.rawValue | NSKeyValueObservingOptions.New.rawValue))
        
        var latest: String?
        
        let d = os .subscribeNext { latest = $0 }
        
        XCTAssertTrue(latest == "0")
        
        testClass.pr = "1"
        
        XCTAssertEqual(latest ?? "", "1")
        
        testClass.pr = "2"
        
        XCTAssertEqual(latest ?? "", "2")
        
        testClass.pr = nil
        
        XCTAssertTrue(latest == nil)
        
        testClass.pr = "3"
        
        XCTAssertEqual(latest ?? "", "3")
        
        d.dispose()
        
        testClass.pr = "4"
        
        XCTAssertEqual(latest ?? "", "3")
    }
    
    func test_Default() {
        let testClass = TestClass()
        
        let os = testClass.rx_observe(String.self, "pr")
        
        var latest: String?
        
        let d = os .subscribeNext { latest = $0 }
        
        XCTAssertTrue(latest == "0")
        
        testClass.pr = "1"
        
        XCTAssertEqual(latest!, "1")
        
        testClass.pr = "2"
        
        XCTAssertEqual(latest!, "2")
        
        testClass.pr = nil
        
        XCTAssertTrue(latest == nil)
        
        testClass.pr = "3"
        
        XCTAssertEqual(latest!, "3")
        
        d.dispose()
        
        testClass.pr = "4"
        
        XCTAssertEqual(latest!, "3")
    }
    
    func test_ObserveAndDontRetainWorks() {
        var latest: String?
        var disposed = false
        
        var parent: Parent! = Parent { n in
            latest = n
        }
        
        _ = parent.rx_deallocated
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
        
        _ = parent.rx_deallocated
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
        
        _ = root.rx_observeWeakly(String.self, "property")
            .subscribeNext { n in
                latest = n
            }
        
        _ = root.rx_deallocated
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
        
        _ = root.rx_observeWeakly(String.self, "property")
            .subscribeNext { n in
                latest = n
        }
        
        _ = root.rx_deallocated
            .subscribeCompleted {
                disposed = true
        }
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(!disposed)
    
        let a: NSString! = "a"
        
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
        
        _ = root.rx_observeWeakly(String.self, "property.property")
            .subscribeNext { n in
                latest = n
            }
        
        _ = root.rx_deallocated
            .subscribeCompleted {
                disposed = true
            }
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        root.property = child
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        let one: NSString! = "1"
        
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
        
        let one: NSString! = "1"
        
        child.property = one
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        _ = root.rx_observeWeakly(String.self, "property.property")
            .subscribeNext { n in
                latest = n
        }
        
        _ = root.rx_deallocated
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
        
        _ = root.rx_observeWeakly(String.self, "property.property")
            .subscribeNext { n in
                latest = n
        }
        
        _ = root.rx_deallocated
            .subscribeCompleted {
                disposed = true
        }
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        root.property = child
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        let one: NSString! = "1"
        
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
        
        let one: NSString! = "1"
        
        child.property = one
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(disposed == false)
        
        _ = root.rx_observeWeakly(String.self, "property.property")
            .subscribeNext { n in
                latest = n
            }
        
        _ = root.rx_deallocated
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
    func _testObserveWeak_Strong_Weak_Observe_NilLastPropertyBecauseOfWeak() -> (HasWeakProperty, NSObject?, Observable<Void>) {
        var dealloc: Observable<Void>! = nil
        let child: HasWeakProperty! = HasWeakProperty()
        var latest: NSObject? = nil
        
        autoreleasepool {
            let root: HasStrongProperty! = HasStrongProperty()
            
            root.property = child
            
            var one: NSObject! = nil
            
            one = NSObject()
            
            child.property = one
            
            XCTAssertTrue(latest == nil)
            
            let observable = root.rx_observeWeakly(NSObject.self, "property.property")
            _ = observable
                .subscribeNext { n in
                    latest = n
                }
            
            XCTAssertTrue(latest! === one)
         
            dealloc = one.rx_deallocating
            
            one = nil
        }
        return (child, latest, dealloc)
    }
    
    func testObserveWeak_Strong_Weak_Observe_NilLastPropertyBecauseOfWeak() {
        var gone = false
        let (child, latest, dealloc) = _testObserveWeak_Strong_Weak_Observe_NilLastPropertyBecauseOfWeak()
        _ = dealloc
            .subscribeNext { n in
                gone = true
            }
        
        XCTAssertTrue(gone)
        XCTAssertTrue(child.property == nil)
        XCTAssertTrue(latest == nil)
    }
    
    func _testObserveWeak_Weak_Weak_Weak_middle_NilifyCorrectly() -> (HasWeakProperty, NSObject?, Observable<Void>) {
        var dealloc: Observable<Void>! = nil
        var middle: HasWeakProperty! = HasWeakProperty()
        var latest: NSObject? = nil
        let root: HasWeakProperty! = HasWeakProperty()
        
        autoreleasepool {
            middle = HasWeakProperty()
            let leaf = HasWeakProperty()
            
            root.property = middle
            middle.property = leaf
            
            XCTAssertTrue(latest == nil)
            
            let observable = root.rx_observeWeakly(NSObject.self, "property.property.property")
            _ = observable
                .subscribeNext { n in
                    latest = n
                }
            
            XCTAssertTrue(latest == nil)
            
            let one = NSObject()
            
            leaf.property = one
            
            XCTAssertTrue(latest === one)
            
            dealloc = middle.rx_deallocating
        }
        return (root!, latest, dealloc)
    }
    
    func testObserveWeak_Weak_Weak_Weak_middle_NilifyCorrectly() {
        let (root, latest, deallocatedMiddle) = _testObserveWeak_Weak_Weak_Weak_middle_NilifyCorrectly()
        
        var gone = false
        
        _ = deallocatedMiddle
            .subscribeCompleted {
                gone = true
            }
        
        XCTAssertTrue(gone)
        XCTAssertTrue(root.property == nil)
        XCTAssertTrue(latest == nil)
    }
    
    func testObserveWeak_TargetDeallocated() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: String? = nil
        
        root.property = "a"
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx_observeWeakly(String.self, "property")
            .subscribeNext { n in
                latest = n
            }
       
        XCTAssertTrue(latest == "a")
     
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeakWithOptions_ObserveNotInitialValue() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: String? = nil
        
        root.property = "a"
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx_observeWeakly(String.self, "property", options: .New)
            .subscribeNext { n in
                latest = n
            }
        
        XCTAssertTrue(latest == nil)
        
        root.property = "b"

        XCTAssertTrue(latest == "b")
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    #if os(OSX)
    // just making sure it's all the same for NS extensions
    func testObserve_ObserveNSRect() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: NSRect? = nil
        
        XCTAssertTrue(latest == nil)
        
        let disposable = root.rx_observe(NSRect.self, "frame")
            .subscribeNext { n in
                latest = n
            }
        XCTAssertTrue(latest == root.frame)
        
        root.frame = NSRect(x: -2, y: 0, width: 0, height: 1)
        
        XCTAssertTrue(latest == NSRect(x: -2, y: 0, width: 0, height: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == NSRect(x: -2, y: 0, width: 0, height: 1))
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }
    #endif

    
    // let's just check for one, otherones should have the same check
    func testObserve_ObserveCGRectForBiggerStructureDoesntCrashPropertyTypeReturnsNil() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGSize? = nil
        
        XCTAssertTrue(latest == nil)
        
        let d = root.rx_observe(CGSize.self, "frame")
            .subscribeNext { n in
                latest = n
            }

        defer {
            d.dispose()
        }

        XCTAssertTrue(latest == nil)
        
        root.size = CGSizeMake(56, 1)
        
        XCTAssertTrue(latest == nil)
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(!rootDeallocated)
    }
    
    func testObserve_ObserveCGRect() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGRect? = nil
        
        XCTAssertTrue(latest == nil)
        
        let d = root.rx_observe(CGRect.self, "frame")
            .subscribeNext { n in
                latest = n
            }

        defer {
            d.dispose()
        }

        XCTAssertTrue(latest == root.frame)
        
        root.frame = CGRectMake(-2, 0, 0, 1)
        
        XCTAssertTrue(latest == CGRectMake(-2, 0, 0, 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == CGRectMake(-2, 0, 0, 1))
        XCTAssertTrue(!rootDeallocated)
    }
    
    func testObserve_ObserveCGSize() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGSize? = nil
        
        XCTAssertTrue(latest == nil)
        
        let d = root.rx_observe(CGSize.self, "size")
            .subscribeNext { n in
                latest = n
            }

        defer {
            d.dispose()
        }

        XCTAssertTrue(latest == root.size)
        
        root.size = CGSizeMake(56, 1)
        
        XCTAssertTrue(latest == CGSizeMake(56, 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == CGSizeMake(56, 1))
        XCTAssertTrue(!rootDeallocated)
    }
    
    func testObserve_ObserveCGPoint() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGPoint? = nil
        
        XCTAssertTrue(latest == nil)
        
        let d = root.rx_observe(CGPoint.self, "point")
            .subscribeNext { n in
                latest = n
            }
        defer {
            d.dispose()
        }
        
        XCTAssertTrue(latest == root.point)
        
        root.point = CGPoint(x: -100, y: 1)
        
        XCTAssertTrue(latest == CGPoint(x: -100, y: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == CGPoint(x: -100, y: 1))
        XCTAssertTrue(!rootDeallocated)
    }
    
    
    func testObserveWeak_ObserveCGRect() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGRect? = nil
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx_observeWeakly(CGRect.self, "frame")
            .subscribeNext { n in
                latest = n
            }
        XCTAssertTrue(latest == root.frame)
        
        root.frame = CGRectMake(-2, 0, 0, 1)
        
        XCTAssertTrue(latest == CGRectMake(-2, 0, 0, 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_ObserveCGSize() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGSize? = nil
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx_observeWeakly(CGSize.self, "size")
            .subscribeNext { n in
                latest = n
            }
        XCTAssertTrue(latest == root.size)
        
        root.size = CGSizeMake(56, 1)
        
        XCTAssertTrue(latest == CGSizeMake(56, 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_ObserveCGPoint() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGPoint? = nil
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx_observeWeakly(CGPoint.self, "point")
            .subscribeNext { n in
                latest = n
            }
        
        XCTAssertTrue(latest == root.point)
        
        root.point = CGPoint(x: -100, y: 1)
        
        XCTAssertTrue(latest == CGPoint(x: -100, y: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_ObserveInt() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: Int? = nil
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx_observeWeakly(NSNumber.self, "integer")
            .subscribeNext { n in
                latest = n?.integerValue
            }
        XCTAssertTrue(latest == root.integer)
        
        root.integer = 10
        
        XCTAssertTrue(latest == 10)
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_PropertyDoesntExist() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var lastError: ErrorType? = nil
        
        _ = root.rx_observeWeakly(NSNumber.self, "notExist")
            .subscribeError { error in
                lastError = error
            }
        
        XCTAssertTrue(lastError != nil)
        lastError = nil

        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_HierarchyPropertyDoesntExist() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var lastError: ErrorType? = nil
        
        _ = root.rx_observeWeakly(NSNumber.self, "property.notExist")
            .subscribeError { error in
                lastError = error
            }
        
        XCTAssertTrue(lastError == nil)
        
        root.property = HasStrongProperty()

        XCTAssertTrue(lastError != nil)
        
        var rootDeallocated = false
        
        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }
        
        root = nil
        
        XCTAssertTrue(rootDeallocated)
    }
}
#endif

// MARK: KVORepresentable

extension KVOObservableTests {
    func testObserve_ObserveIntegerRepresentable() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: Int?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx_observe(Int.self, "integer")
            .subscribeNext { n in
                latest = n
            }
        XCTAssertTrue(latest == 1)

        root.integer = 2

        XCTAssertTrue(latest == 2)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }

        root = nil

        XCTAssertTrue(latest == 2)
        XCTAssertTrue(!rootDeallocated)

        disposable.dispose()
    }

    func testObserve_ObserveUIntegerRepresentable() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx_observe(UInt.self, "uinteger")
            .subscribeNext { n in
                latest = n
        }
        XCTAssertTrue(latest == 1)

        root.uinteger = 2

        XCTAssertTrue(latest == 2)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }

        root = nil

        XCTAssertTrue(latest == 2)
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }
}

#if !DISABLE_SWIZZLING
    extension KVOObservableTests {
        func testObserveWeak_ObserveIntegerRepresentable() {
            var root: HasStrongProperty! = HasStrongProperty()

            var latest: Int?

            XCTAssertTrue(latest == nil)

            _ = root
                .rx_observeWeakly(Int.self, "integer")
                .subscribeNext { n in
                    latest = n
                }

            XCTAssertTrue(latest == 1)

            root.integer = 2

            XCTAssertTrue(latest == 2)

            var rootDeallocated = false

            _ = root
                .rx_deallocated
                .subscribeCompleted {
                    rootDeallocated = true
            }
            
            root = nil
            
            XCTAssertTrue(latest == nil)
            XCTAssertTrue(rootDeallocated)
        }

        func testObserveWeak_ObserveUIntegerRepresentable() {
            var root: HasStrongProperty! = HasStrongProperty()

            var latest: UInt?

            XCTAssertTrue(latest == nil)

            _ = root
                .rx_observeWeakly(UInt.self, "uinteger")
                .subscribeNext { n in
                    latest = n
            }

            XCTAssertTrue(latest == 1)

            root.uinteger = 2

            XCTAssertTrue(latest == 2)

            var rootDeallocated = false

            _ = root
                .rx_deallocated
                .subscribeCompleted {
                    rootDeallocated = true
            }

            root = nil

            XCTAssertTrue(latest == nil)
            XCTAssertTrue(rootDeallocated)
        }
    }
#endif

// MARK: RawRepresentable
extension KVOObservableTests {
    func testObserve_ObserveIntEnum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: IntEnum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx_observe(IntEnum.self, "intEnum")
            .subscribeNext { n in
                latest = n
            }
        XCTAssertTrue(latest == .One)

        root.intEnum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }

        root = nil

        XCTAssertTrue(latest == .Two)
        XCTAssertTrue(!rootDeallocated)

        disposable.dispose()
    }

    func testObserve_ObserveInt32Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: Int32Enum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx_observe(Int32Enum.self, "int32Enum")
            .subscribeNext { n in
                latest = n
        }
        XCTAssertTrue(latest == .One)

        root.int32Enum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }

        root = nil

        XCTAssertTrue(latest == .Two)
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }

    func testObserve_ObserveInt64Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: Int64Enum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx_observe(Int64Enum.self, "int64Enum")
            .subscribeNext { n in
                latest = n
        }
        XCTAssertTrue(latest == .One)

        root.int64Enum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }

        root = nil

        XCTAssertTrue(latest == .Two)
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }


    func testObserve_ObserveUIntEnum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UIntEnum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx_observe(UIntEnum.self, "uintEnum")
            .subscribeNext { n in
                latest = n
            }
        XCTAssertTrue(latest == .One)

        root.uintEnum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }

        root = nil

        XCTAssertTrue(latest == .Two)
        XCTAssertTrue(!rootDeallocated)

        disposable.dispose()
    }

    func testObserve_ObserveUInt32Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt32Enum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx_observe(UInt32Enum.self, "uint32Enum")
            .subscribeNext { n in
                latest = n
        }
        XCTAssertTrue(latest == .One)

        root.uint32Enum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }

        root = nil

        XCTAssertTrue(latest == .Two)
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }

    func testObserve_ObserveUInt64Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt64Enum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx_observe(UInt64Enum.self, "uint64Enum")
            .subscribeNext { n in
                latest = n
        }
        XCTAssertTrue(latest == .One)

        root.uint64Enum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }

        root = nil

        XCTAssertTrue(latest == .Two)
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }
}

#if !DISABLE_SWIZZLING
extension KVOObservableTests {
    func testObserveWeak_ObserveIntEnum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: IntEnum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx_observeWeakly(IntEnum.self, "intEnum")
            .subscribeNext { n in
                latest = n
            }
        XCTAssertTrue(latest == .One)

        root.intEnum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveInt32Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: Int32Enum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx_observeWeakly(Int32Enum.self, "int32Enum")
            .subscribeNext { n in
                latest = n
        }
        XCTAssertTrue(latest == .One)

        root.int32Enum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveInt64Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: Int64Enum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx_observeWeakly(Int64Enum.self, "int64Enum")
            .subscribeNext { n in
                latest = n
        }
        XCTAssertTrue(latest == .One)

        root.int64Enum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveUIntEnum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UIntEnum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx_observeWeakly(UIntEnum.self, "uintEnum")
            .subscribeNext { n in
                latest = n
            }
        XCTAssertTrue(latest == .One)

        root.uintEnum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
            }

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveUInt32Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt32Enum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx_observeWeakly(UInt32Enum.self, "uint32Enum")
            .subscribeNext { n in
                latest = n
        }
        XCTAssertTrue(latest == .One)

        root.uint32Enum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveUInt64Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt32Enum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx_observeWeakly(UInt32Enum.self, "uint64Enum")
            .subscribeNext { n in
                latest = n
        }
        XCTAssertTrue(latest == .One)

        root.uint64Enum = .Two

        XCTAssertTrue(latest == .Two)

        var rootDeallocated = false

        _ = root
            .rx_deallocated
            .subscribeCompleted {
                rootDeallocated = true
        }

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
}
#endif
