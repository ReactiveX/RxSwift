//
//  KVOObservableTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 5/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif


final class KVOObservableTests : RxTest {
    var parent: Parent!
    var parentWithChild: ParentWithChild!
    var hasStrongProperty: HasStrongProperty!
    var hasWeakProperty: HasWeakProperty!
    fileprivate var testClass: TestClass!
}

private final class TestClass : NSObject {
    @objc dynamic var pr: String? = "0"
}

final class Parent : NSObject {
    var disposeBag: DisposeBag! = DisposeBag()

    @objc dynamic var val: String = ""

    init(callback: @escaping (String?) -> Void) {
        super.init()
        
        self.rx.observe(String.self, "val", options: [.initial, .new], retainSelf: false)
            .subscribe(onNext: callback)
            .disposed(by: disposeBag)
    }
    
    deinit {
        disposeBag = nil
    }
}

final class Child : NSObject {
    let disposeBag = DisposeBag()
    
    init(parent: ParentWithChild, callback: @escaping (String?) -> Void) {
        super.init()
        parent.rx.observe(String.self, "val", options: [.initial, .new], retainSelf: false)
            .subscribe(onNext: callback)
            .disposed(by: disposeBag)
    }
    
    deinit {
        
    }
}

final class ParentWithChild : NSObject {
    @objc dynamic var val: String = ""
    
    var child: Child? = nil
    
    init(callback: @escaping (String?) -> Void) {
        super.init()
        child = Child(parent: self, callback: callback)
    }
}

@objc enum IntEnum: Int {
    typealias RawValue = Int
    case one
    case two
}

@objc enum UIntEnum: UInt {
    case one
    case two
}

@objc enum Int32Enum: Int32 {
    case one
    case two
}

@objc enum UInt32Enum: UInt32 {
    case one
    case two
}

@objc enum Int64Enum: Int64 {
    case one
    case two
}

@objc enum UInt64Enum: UInt64 {
    case one
    case two
}

final class HasStrongProperty : NSObject {
    @objc dynamic var property: NSObject? = nil
    @objc dynamic var frame: CGRect
    @objc dynamic var point: CGPoint
    @objc dynamic var size: CGSize
    @objc dynamic var intEnum: IntEnum = .one
    @objc dynamic var uintEnum: UIntEnum = .one
    @objc dynamic var int32Enum: Int32Enum = .one
    @objc dynamic var uint32Enum: UInt32Enum = .one
    @objc dynamic var int64Enum: Int64Enum = .one
    @objc dynamic var uint64Enum: UInt64Enum = .one
    
    @objc dynamic var integer: Int
    @objc dynamic var uinteger: UInt
    
    override init() {
        self.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.point = CGPoint(x: 3, y: 5)
        self.size = CGSize(width: 1, height: 2)
        
        self.integer = 1
        self.uinteger = 1
        super.init()
    }
}

final class HasWeakProperty : NSObject {
    @objc dynamic weak var property: NSObject? = nil
    
    override init() {
        super.init()
    }
}

// MARK: Test key path observation
extension KVOObservableTests {
    func testKeyPathObservation_DefaultOptions() {
        testClass = TestClass()
        let os = testClass.rx.observe(\.pr)
        var latest: String?
        var completed = false

        _ = os.subscribe(onNext: { latest = $0 },
                         onCompleted: { completed = true })

        testClass.pr = "1"
        XCTAssertEqual(latest!, "1")

        testClass.pr = "2"
        XCTAssertEqual(latest!, "2")

        testClass.pr = nil
        XCTAssertTrue(latest == nil)

        testClass.pr = "3"
        XCTAssertEqual(latest!, "3")

        XCTAssertFalse(completed)
        testClass = nil
        XCTAssertTrue(completed)

        XCTAssertEqual(latest!, "3")
    }

    func testKeyPathObservation_NewAndInitialOptions() {
        let testClass = TestClass()
        let os = testClass.rx.observe(\.pr, options: [.new, .initial])
        var latest: String?

        let d = os.subscribe(onNext: { latest = $0 })
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

    func testKeyPathObservation_NewOptions() {
        testClass = TestClass()
        let os = testClass.rx.observe(\.pr, options: [.new])
        var latest: String?
        var completed = false

        _ = os.subscribe(onNext: { latest = $0 },
                         onCompleted: { completed = true })

        XCTAssertNil(latest)

        testClass.pr = "1"
        XCTAssertEqual(latest!, "1")

        testClass.pr = "2"
        XCTAssertEqual(latest!, "2")

        testClass.pr = nil
        XCTAssertTrue(latest == nil)

        testClass.pr = "3"
        XCTAssertEqual(latest!, "3")

        XCTAssertFalse(completed)
        testClass = nil
        XCTAssertTrue(completed)

        XCTAssertEqual(latest!, "3")
    }
}

// MARK: Test fast observe
extension KVOObservableTests {
    func test_New() {
        let testClass = TestClass()
        
        let os = testClass.rx.observe(String.self, "pr", options: .new)
        
        var latest: String?
        
        let d = os.subscribe(onNext: { latest = $0 })
        
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
        
        let os = testClass.rx.observe(String.self, "pr", options: [.initial, .new])
        
        var latest: String?
        
        let d = os.subscribe(onNext: { latest = $0 })
        
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
        
        let os = testClass.rx.observe(String.self, "pr")
        
        var latest: String?
        
        let d = os.subscribe(onNext: { latest = $0 })
        
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
        var isDisposed = false

        parent = Parent { n in
            latest = n
        }
        
        _ = parent.rx.deallocated
            .subscribe(onCompleted: {
                isDisposed = true
            })

        XCTAssertTrue(latest == "")
        XCTAssertTrue(isDisposed == false)
        
        parent.val = "1"
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(isDisposed == false)
        
        parent = nil

        XCTAssertTrue(latest == "1")
        XCTAssertTrue(isDisposed == true)
    }
    
    func test_ObserveAndDontRetainWorks2() {
        var latest: String?
        var isDisposed = false
        
        parentWithChild = ParentWithChild { n in
            latest = n
        }
        
        _ = parentWithChild.rx.deallocated
            .subscribe(onCompleted: {
                isDisposed = true
            })

        XCTAssertTrue(latest == "")
        XCTAssertTrue(isDisposed == false)
        
        parentWithChild.val = "1"
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(isDisposed == false)
        
        parentWithChild = nil
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(isDisposed == true)
    }
}

#if !DISABLE_SWIZZLING
// test weak observe 

extension KVOObservableTests {
    
    func testObserveWeak_SimpleStrongProperty() {
        var latest: String?
        var isDisposed = false
        
        hasStrongProperty = HasStrongProperty()
        
        _ = hasStrongProperty.rx.observeWeakly(String.self, "property")
            .subscribe(onNext: { n in
                latest = n
            })
        
        _ = hasStrongProperty.rx.deallocated
            .subscribe(onCompleted: {
                isDisposed = true
            })

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(!isDisposed)
        
        hasStrongProperty.property = "a".duplicate()

        XCTAssertTrue(latest == "a")
        XCTAssertTrue(!isDisposed)
        
        hasStrongProperty = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed)
    }
    
    func testObserveWeak_SimpleWeakProperty() {
        var latest: String?
        var isDisposed = false
        
        hasWeakProperty = HasWeakProperty()
        
        _ = hasWeakProperty.rx.observeWeakly(String.self, "property")
            .subscribe(onNext: { n in
                latest = n
        })
        
        _ = hasWeakProperty.rx.deallocated
            .subscribe(onCompleted: {
                isDisposed = true
        })

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(!isDisposed)
    
        let a: NSString! = "a".duplicate()
        
        hasWeakProperty.property = a
        
        XCTAssertTrue(latest == "a")
        XCTAssertTrue(!isDisposed)
        
        hasWeakProperty = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed)
    }

    func testObserveWeak_ObserveFirst_Weak_Strong_Basic() {
        var latest: String?
        var isDisposed = false
        
        hasStrongProperty = HasStrongProperty()
        hasWeakProperty = HasWeakProperty()
        
        _ = hasWeakProperty.rx.observeWeakly(String.self, "property.property")
            .subscribe(onNext: { n in
                latest = n
            })
        
        _ = hasWeakProperty.rx.deallocated
            .subscribe(onCompleted: {
                isDisposed = true
            })

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == false)
        
        hasWeakProperty.property = hasStrongProperty
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == false)
        
        let one: NSString! = "1".duplicate()
        
        hasStrongProperty.property = one
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(isDisposed == false)
        
        hasWeakProperty = nil
        hasStrongProperty = nil
     
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == true)
    }
    
    func testObserveWeak_Weak_Strong_Observe_Basic() {
        var latest: String?
        var isDisposed = false
        
        hasStrongProperty = HasStrongProperty()
        hasWeakProperty = HasWeakProperty()
        
        hasWeakProperty.property = hasStrongProperty
        
        let one: NSString! = "1".duplicate()
        
        hasStrongProperty.property = one
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == false)
        
        _ = hasWeakProperty.rx.observeWeakly(String.self, "property.property")
            .subscribe(onNext: { n in
                latest = n
        })
        
        _ = hasWeakProperty.rx.deallocated
            .subscribe(onCompleted: {
                isDisposed = true
        })

        XCTAssertTrue(latest == "1")
        XCTAssertTrue(isDisposed == false)
        
        hasWeakProperty = nil
        hasStrongProperty = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == true)
    }
    
    func testObserveWeak_ObserveFirst_Strong_Weak_Basic() {
        var latest: String?
        var isDisposed = false
        
        hasWeakProperty = HasWeakProperty()
        hasStrongProperty = HasStrongProperty()
        
        _ = hasStrongProperty.rx.observeWeakly(String.self, "property.property")
            .subscribe(onNext: { n in
                latest = n
        })
        
        _ = hasStrongProperty.rx.deallocated
            .subscribe(onCompleted: {
                isDisposed = true
        })

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == false)
        
        hasStrongProperty.property = hasWeakProperty
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == false)
        
        let one: NSString! = "1".duplicate()
        
        hasWeakProperty.property = one
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(isDisposed == false)
        
        hasStrongProperty = nil
        hasWeakProperty = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == true)
    }
    
    func testObserveWeak_Strong_Weak_Observe_Basic() {
        var latest: String?
        var isDisposed = false
        
        hasWeakProperty = HasWeakProperty()
        hasStrongProperty = HasStrongProperty()
        
        hasStrongProperty.property = hasWeakProperty
        
        let one: NSString! = "1".duplicate()
        
        hasWeakProperty.property = one
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == false)
        
        _ = hasStrongProperty.rx.observeWeakly(String.self, "property.property")
            .subscribe(onNext: { n in
                latest = n
            })
        
        _ = hasStrongProperty.rx.deallocated
            .subscribe(onCompleted: {
                isDisposed = true
        })

        XCTAssertTrue(latest == "1")
        XCTAssertTrue(isDisposed == false)
        
        hasStrongProperty = nil
        hasWeakProperty = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(isDisposed == true)
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
            
            let observable = root.rx.observeWeakly(NSObject.self, "property.property")
            _ = observable
                .subscribe(onNext: { n in
                    latest = n
                })
            
            XCTAssertTrue(latest! === one)
         
            dealloc = one.rx.deallocating
            
            one = nil
        }
        return (child, latest, dealloc)
    }
    
    func testObserveWeak_Strong_Weak_Observe_NilLastPropertyBecauseOfWeak() {
        var gone = false
        let (child, latest, dealloc) = _testObserveWeak_Strong_Weak_Observe_NilLastPropertyBecauseOfWeak()
        _ = dealloc
            .subscribe(onNext: { n in
                gone = true
            })
        
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
            
            let observable = root.rx.observeWeakly(NSObject.self, "property.property.property")
            _ = observable
                .subscribe(onNext: { n in
                    latest = n
                })
            
            XCTAssertTrue(latest == nil)
            
            let one = NSObject()
            
            leaf.property = one
            
            XCTAssertTrue(latest === one)
            
            dealloc = middle.rx.deallocating
        }
        return (root!, latest, dealloc)
    }
    
    func testObserveWeak_Weak_Weak_Weak_middle_NilifyCorrectly() {
        let (root, latest, deallocatedMiddle) = _testObserveWeak_Weak_Weak_Weak_middle_NilifyCorrectly()
        
        var gone = false
        
        _ = deallocatedMiddle
            .subscribe(onCompleted: {
                gone = true
            })
        
        XCTAssertTrue(gone)
        XCTAssertTrue(root.property == nil)
        XCTAssertTrue(latest == nil)
    }
    
    func testObserveWeak_TargetDeallocated() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: String? = nil
        
        root.property = "a".duplicate()
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx.observeWeakly(String.self, "property")
            .subscribe(onNext: { n in
                latest = n
            })
       
        XCTAssertTrue(latest == "a")
     
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeakWithOptions_ObserveNotInitialValue() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: String? = nil
        
        root.property = "a".duplicate()
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx.observeWeakly(String.self, "property", options: .new)
            .subscribe(onNext: { n in
                latest = n
            })
        
        XCTAssertTrue(latest == nil)
        
        root.property = "b".duplicate()

        XCTAssertTrue(latest == "b")
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    #if os(macOS)
    // just making sure it's all the same for NS extensions
    func testObserve_ObserveNSRect() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: NSRect? = nil
        
        XCTAssertTrue(latest == nil)
        
        let disposable = root.rx.observe(NSRect.self, "frame")
            .subscribe(onNext: { n in
                latest = n
            })
        XCTAssertTrue(latest == root.frame)
        
        root.frame = NSRect(x: -2, y: 0, width: 0, height: 1)
        
        XCTAssertTrue(latest == NSRect(x: -2, y: 0, width: 0, height: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
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
        
        let d = root.rx.observe(CGSize.self, "frame")
            .subscribe(onNext: { n in
                latest = n
            })

        defer {
            d.dispose()
        }

        XCTAssertTrue(latest == nil)
        
        root.size = CGSize(width: 56, height: 1)
        
        XCTAssertTrue(latest == nil)
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(!rootDeallocated)
    }
    
    func testObserve_ObserveCGRect() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGRect? = nil
        
        XCTAssertTrue(latest == nil)
        
        let d = root.rx.observe(CGRect.self, "frame")
            .subscribe(onNext: { n in
                latest = n
            })

        defer {
            d.dispose()
        }

        XCTAssertTrue(latest == root.frame)
        
        root.frame = CGRect(x: -2, y: 0, width: 0, height: 1)
        
        XCTAssertTrue(latest == CGRect(x: -2, y: 0, width: 0, height: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == CGRect(x: -2, y: 0, width: 0, height: 1))
        XCTAssertTrue(!rootDeallocated)
    }
    
    func testObserve_ObserveCGSize() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGSize? = nil
        
        XCTAssertTrue(latest == nil)
        
        let d = root.rx.observe(CGSize.self, "size")
            .subscribe(onNext: { n in
                latest = n
            })

        defer {
            d.dispose()
        }

        XCTAssertTrue(latest == root.size)
        
        root.size = CGSize(width: 56, height: 1)
        
        XCTAssertTrue(latest == CGSize(width: 56, height: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == CGSize(width: 56, height: 1))
        XCTAssertTrue(!rootDeallocated)
    }
    
    func testObserve_ObserveCGPoint() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGPoint? = nil
        
        XCTAssertTrue(latest == nil)
        
        let d = root.rx.observe(CGPoint.self, "point")
            .subscribe(onNext: { n in
                latest = n
            })
        defer {
            d.dispose()
        }
        
        XCTAssertTrue(latest == root.point)
        
        root.point = CGPoint(x: -100, y: 1)
        
        XCTAssertTrue(latest == CGPoint(x: -100, y: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == CGPoint(x: -100, y: 1))
        XCTAssertTrue(!rootDeallocated)
    }
    
    
    func testObserveWeak_ObserveCGRect() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGRect? = nil
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx.observeWeakly(CGRect.self, "frame")
            .subscribe(onNext: { n in
                latest = n
            })
        XCTAssertTrue(latest == root.frame)
        
        root.frame = CGRect(x: -2, y: 0, width: 0, height: 1)
        
        XCTAssertTrue(latest == CGRect(x: -2, y: 0, width: 0, height: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_ObserveCGSize() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGSize? = nil
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx.observeWeakly(CGSize.self, "size")
            .subscribe(onNext: { n in
                latest = n
            })
        XCTAssertTrue(latest == root.size)
        
        root.size = CGSize(width: 56, height: 1)
        
        XCTAssertTrue(latest == CGSize(width: 56, height: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_ObserveCGPoint() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: CGPoint? = nil
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx.observeWeakly(CGPoint.self, "point")
            .subscribe(onNext: { n in
                latest = n
            })
        
        XCTAssertTrue(latest == root.point)
        
        root.point = CGPoint(x: -100, y: 1)
        
        XCTAssertTrue(latest == CGPoint(x: -100, y: 1))
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_ObserveInt() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var latest: Int? = nil
        
        XCTAssertTrue(latest == nil)
        
        _ = root
            .rx.observeWeakly(NSNumber.self, "integer")
            .subscribe(onNext: { n in
                latest = n?.intValue
            })
        XCTAssertTrue(latest == root.integer)
        
        root.integer = 10
        
        XCTAssertTrue(latest == 10)
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_PropertyDoesntExist() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var lastError: Swift.Error? = nil
        
        _ = root.rx.observeWeakly(NSNumber.self, "notExist")
            .subscribe(onError: { error in
                lastError = error
            })
        
        XCTAssertTrue(lastError != nil)
        lastError = nil

        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
        root = nil
        
        XCTAssertTrue(rootDeallocated)
    }
    
    func testObserveWeak_HierarchyPropertyDoesntExist() {
        var root: HasStrongProperty! = HasStrongProperty()
        
        var lastError: Swift.Error? = nil
        
        _ = root.rx.observeWeakly(NSNumber.self, "property.notExist")
            .subscribe(onError: { error in
                lastError = error
            })
        
        XCTAssertTrue(lastError == nil)
        
        root.property = HasStrongProperty()

        XCTAssertTrue(lastError != nil)
        
        var rootDeallocated = false
        
        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })
        
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

        let disposable = root.rx.observe(Int.self, "integer")
            .subscribe(onNext: { n in
                latest = n
            })
        XCTAssertTrue(latest == 1)

        root.integer = 2

        XCTAssertTrue(latest == 2)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == 2)
        XCTAssertTrue(!rootDeallocated)

        disposable.dispose()
    }

    func testObserve_ObserveUIntegerRepresentable() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx.observe(UInt.self, "uinteger")
            .subscribe(onNext: { n in
                latest = n
        })
        XCTAssertTrue(latest == 1)

        root.uinteger = 2

        XCTAssertTrue(latest == 2)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

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
                .rx.observeWeakly(Int.self, "integer")
                .subscribe(onNext: { n in
                    latest = n
                })

            XCTAssertTrue(latest == 1)

            root.integer = 2

            XCTAssertTrue(latest == 2)

            var rootDeallocated = false

            _ = root
                .rx.deallocated
                .subscribe(onCompleted: {
                    rootDeallocated = true
                })
            
            root = nil
            
            XCTAssertTrue(latest == nil)
            XCTAssertTrue(rootDeallocated)
        }

        func testObserveWeak_ObserveUIntegerRepresentable() {
            var root: HasStrongProperty! = HasStrongProperty()

            var latest: UInt?

            XCTAssertTrue(latest == nil)

            _ = root
                .rx.observeWeakly(UInt.self, "uinteger")
                .subscribe(onNext: { n in
                    latest = n
                })

            XCTAssertTrue(latest == 1)

            root.uinteger = 2

            XCTAssertTrue(latest == 2)

            var rootDeallocated = false

            _ = root
                .rx.deallocated
                .subscribe(onCompleted: {
                    rootDeallocated = true
                })

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

        let disposable = root.rx.observe(IntEnum.self, "intEnum")
            .subscribe(onNext: { n in
                latest = n
            })
        XCTAssertTrue(latest == .one)

        root.intEnum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == .two)
        XCTAssertTrue(!rootDeallocated)

        disposable.dispose()
    }

    func testObserve_ObserveInt32Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: Int32Enum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx.observe(Int32Enum.self, "int32Enum")
            .subscribe(onNext: { n in
                latest = n
        })
        XCTAssertTrue(latest == .one)

        root.int32Enum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == .two)
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }

    func testObserve_ObserveInt64Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: Int64Enum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx.observe(Int64Enum.self, "int64Enum")
            .subscribe(onNext: { n in
                latest = n
        })
        XCTAssertTrue(latest == .one)

        root.int64Enum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == .two)
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }


    func testObserve_ObserveUIntEnum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UIntEnum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx.observe(UIntEnum.self, "uintEnum")
            .subscribe(onNext: { n in
                latest = n
            })
        XCTAssertTrue(latest == .one)

        root.uintEnum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == .two)
        XCTAssertTrue(!rootDeallocated)

        disposable.dispose()
    }

    func testObserve_ObserveUInt32Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt32Enum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx.observe(UInt32Enum.self, "uint32Enum")
            .subscribe(onNext: { n in
                latest = n
        })
        XCTAssertTrue(latest == .one)

        root.uint32Enum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == .two)
        XCTAssertTrue(!rootDeallocated)
        
        disposable.dispose()
    }

    func testObserve_ObserveUInt64Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt64Enum?

        XCTAssertTrue(latest == nil)

        let disposable = root.rx.observe(UInt64Enum.self, "uint64Enum")
            .subscribe(onNext: { n in
                latest = n
        })
        XCTAssertTrue(latest == .one)

        root.uint64Enum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == .two)
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
            .rx.observeWeakly(IntEnum.self, "intEnum")
            .subscribe(onNext: { n in
                latest = n
            })
        XCTAssertTrue(latest == .one)

        root.intEnum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveInt32Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: Int32Enum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx.observeWeakly(Int32Enum.self, "int32Enum")
            .subscribe(onNext: { n in
                latest = n
        })
        XCTAssertTrue(latest == .one)

        root.int32Enum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveInt64Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: Int64Enum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx.observeWeakly(Int64Enum.self, "int64Enum")
            .subscribe(onNext: { n in
                latest = n
        })
        XCTAssertTrue(latest == .one)

        root.int64Enum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveUIntEnum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UIntEnum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx.observeWeakly(UIntEnum.self, "uintEnum")
            .subscribe(onNext: { n in
                latest = n
            })
        XCTAssertTrue(latest == .one)

        root.uintEnum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveUInt32Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt32Enum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx.observeWeakly(UInt32Enum.self, "uint32Enum")
            .subscribe(onNext: { n in
                latest = n
        })
        XCTAssertTrue(latest == .one)

        root.uint32Enum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }

    func testObserveWeak_ObserveUInt64Enum() {
        var root: HasStrongProperty! = HasStrongProperty()

        var latest: UInt32Enum?

        XCTAssertTrue(latest == nil)

        _ = root
            .rx.observeWeakly(UInt32Enum.self, "uint64Enum")
            .subscribe(onNext: { n in
                latest = n
        })
        XCTAssertTrue(latest == .one)

        root.uint64Enum = .two

        XCTAssertTrue(latest == .two)

        var rootDeallocated = false

        _ = root
            .rx.deallocated
            .subscribe(onCompleted: {
                rootDeallocated = true
            })

        root = nil

        XCTAssertTrue(latest == nil)
        XCTAssertTrue(rootDeallocated)
    }
}
#endif


extension NSString {
    func duplicate() -> NSString {
        NSMutableString(string: self)
    }
}

