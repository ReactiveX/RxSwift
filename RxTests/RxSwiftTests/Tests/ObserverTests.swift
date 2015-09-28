//
//  ObserverTests.swift
//  RxTests
//
//  Created by Rob Cheung on 9/15/15.
//
//

import XCTest
import RxSwift

class ObserverTests: RxTest { }

extension ObserverTests {
    
    func testConvenienceOn_Next() {
        var observer: ObserverOf<Int>!
        let a: Observable<Int> = create { o in
            observer = o
            return NopDisposable.instance
        }
        
        var elements = [Int]()
        
        a.subscribeNext { n in
            elements.append(n)
        }
        
        XCTAssertEqual(elements, [])
        
        observer.onNext(0)
        
        XCTAssertEqual(elements, [0])
    }
    
    func testConvenienceOn_Error() {
        var observer: ObserverOf<Int>!
        let a: Observable<Int> = create { o in
            observer = o
            return NopDisposable.instance
        }
        
        var elements = [Int]()
        var errrorNotification: NSError!
        
        a.subscribe(
            next: { n in elements.append(n) },
            error: { e in
                errrorNotification = e as NSError
            }
        )
        
        XCTAssertEqual(elements, [])
        
        observer.onNext(0)
        XCTAssertEqual(elements, [0])
        
        observer.onError(testError)
        
        observer.onNext(1)
        XCTAssertEqual(elements, [0])
        XCTAssertEqual(errrorNotification, testError)
    }
    
    func testConvenienceOn_Complete() {
        var observer: ObserverOf<Int>!
        let a: Observable<Int> = create { o in
            observer = o
            return NopDisposable.instance
        }
        
        var elements = [Int]()
        
        a.subscribeNext { n in
            elements.append(n)
        }
        
        XCTAssertEqual(elements, [])
        
        observer.onNext(0)
        XCTAssertEqual(elements, [0])
        
        observer.onComplete()
        
        observer.onNext(1)
        XCTAssertEqual(elements, [0])
    }
}