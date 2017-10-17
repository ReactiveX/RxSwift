//
//  UIScrollView+RxTests.swift
//  Tests
//
//  Created by Suyeol Jeon on 6/8/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import RxSwift
import RxCocoa
import UIKit
import XCTest
import RxTest

final class UIScrollViewTests : RxTest {}

extension UIScrollViewTests {

    func testScrollEnabled_False() {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true

        Observable.just(false).bind(to: scrollView.rx.isScrollEnabled).dispose()
        XCTAssertTrue(scrollView.isScrollEnabled == false)
    }

    func testScrollEnabled_True() {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.isScrollEnabled = false

        Observable.just(true).bind(to: scrollView.rx.isScrollEnabled).dispose()
        XCTAssertTrue(scrollView.isScrollEnabled == true)
    }

    func testScrollView_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIScrollView = { UIScrollView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, CGPoint(x: 1, y: 1)) { (view: UIScrollView) in view.rx.contentOffset }
    }

    func testScrollViewDidScroll() {
        var completed = false
        
        autoreleasepool {
            let scrollView = UIScrollView()
            var didScroll = false

            _ = scrollView.rx.didScroll.subscribe(onNext: { _ in
                didScroll = true
            }, onCompleted: {
                completed = true
            })

            XCTAssertFalse(didScroll)

            scrollView.delegate!.scrollViewDidScroll!(scrollView)

            XCTAssertTrue(didScroll)
        }

        XCTAssertTrue(completed)
    }
	
    func testScrollViewWillBeginDecelerating() {
        var completed = false

        autoreleasepool {
            let scrollView = UIScrollView()
            var willBeginDecelerating = false

            _ = scrollView.rx.willBeginDecelerating.subscribe(onNext: { _ in
                willBeginDecelerating = true
            }, onCompleted: {
                completed = true
            })

            XCTAssertFalse(willBeginDecelerating)

            scrollView.delegate!.scrollViewWillBeginDecelerating!(scrollView)

            XCTAssertTrue(willBeginDecelerating)
        }

        XCTAssertTrue(completed)
    }
	
	func testScrollViewDidEndDecelerating() {
		var completed = false
		
		autoreleasepool {
			let scrollView = UIScrollView()
			var didEndDecelerating = false
			
			_ = scrollView.rx.didEndDecelerating.subscribe(onNext: { _ in
				didEndDecelerating = true
			}, onCompleted: {
				completed = true
			})
			
			XCTAssertFalse(didEndDecelerating)
			
			scrollView.delegate!.scrollViewDidEndDecelerating!(scrollView)
			
			XCTAssertTrue(didEndDecelerating)
		}
		
		XCTAssertTrue(completed)
	}

    func testScrollViewWillBeginDragging() {
        var completed = false

        autoreleasepool {
            let scrollView = UIScrollView()
            var willBeginDragging = false

            _ = scrollView.rx.willBeginDragging.subscribe(onNext: { _ in
                willBeginDragging = true
            }, onCompleted: {
                completed = true
            })

            XCTAssertFalse(willBeginDragging)

            scrollView.delegate!.scrollViewWillBeginDragging!(scrollView)

            XCTAssertTrue(willBeginDragging)
        }

        XCTAssertTrue(completed)
    }
	
    func testScrollViewWillEndDragging() {
        var completed = false
        
        autoreleasepool {
            let scrollView = UIScrollView()

            let positiveVelocity = CGPoint(x: 1.5, y: 2.5)
            var positiveOffset = CGPoint(x: 27.4, y: 853.0)

            let negativeVelocity = CGPoint(x: 1.5, y: 2.5)
            var zeroOffset = CGPoint.zero

            var velocity: CGPoint? = nil
            var offset: CGPoint? = nil

            _ = scrollView.rx.willEndDragging.subscribe(onNext: {
                velocity = $0
                offset = $1.pointee
            }, onCompleted: {
                completed = true
            })
            
            XCTAssertNil(velocity)
            XCTAssertNil(offset)

            scrollView.delegate!.scrollViewWillEndDragging!(scrollView, withVelocity: positiveVelocity, targetContentOffset: &positiveOffset)

            XCTAssertEqual(positiveVelocity, velocity)
            XCTAssertEqual(positiveOffset, offset)

            scrollView.delegate!.scrollViewWillEndDragging!(scrollView, withVelocity: negativeVelocity, targetContentOffset: &zeroOffset)

            XCTAssertEqual(negativeVelocity, velocity)
            XCTAssertEqual(zeroOffset, offset)
        }
        
        XCTAssertTrue(completed)
    }

    func testScrollViewWillEndDraggingWithModifyingOffset() {
        var completed = false

        autoreleasepool {
            let scrollView = UIScrollView()

            var initialOffset = CGPoint(x: 27.4, y: 853.0)
            let changedOffset = CGPoint(x: 42.5, y: 97.4)

            _ = scrollView.rx.willEndDragging.subscribe(onNext: {
                $1.pointee = changedOffset
            }, onCompleted: {
                completed = true
            })

            XCTAssertNotEqual(changedOffset, initialOffset)

            scrollView.delegate!.scrollViewWillEndDragging!(scrollView, withVelocity: CGPoint.zero, targetContentOffset: &initialOffset)

            XCTAssertEqual(changedOffset, initialOffset)
        }

        XCTAssertTrue(completed)
    }

	func testScrollViewDidEndDragging() {
		var completed = false
		
		autoreleasepool {
			let scrollView = UIScrollView()
			var results: [Bool] = []
			
			_ = scrollView.rx.didEndDragging.subscribe(onNext: {
				results.append($0)
			}, onCompleted: {
				completed = true
			})
			
			XCTAssertTrue(results.isEmpty)
			
			scrollView.delegate!.scrollViewDidEndDragging!(scrollView, willDecelerate: false)
			scrollView.delegate!.scrollViewDidEndDragging!(scrollView, willDecelerate: true)
			
			XCTAssertEqual(results, [false, true])
		}
		
		XCTAssertTrue(completed)
		
    }

    func testScrollViewContentOffset() {
        var completed = false

        autoreleasepool {
            let scrollView = UIScrollView()
            scrollView.contentOffset = .zero

            var contentOffset = CGPoint(x: -1, y: -1)

            _ = scrollView.rx.contentOffset.subscribe(onNext: { value in
                contentOffset = value
            }, onCompleted: {
                completed = true
            })

            XCTAssertEqual(contentOffset, .zero)

            scrollView.contentOffset = CGPoint(x: 2, y: 2)
            scrollView.delegate!.scrollViewDidScroll!(scrollView)

            XCTAssertEqual(contentOffset, CGPoint(x: 2, y: 2))
        }

        XCTAssertTrue(completed)
    }

    func testScrollViewDidZoom() {
        let scrollView = UIScrollView()
        var didZoom = false

        let subscription = scrollView.rx.didZoom.subscribe(onNext: { _ in
            didZoom = true
        })

        XCTAssertFalse(didZoom)

        scrollView.delegate!.scrollViewDidZoom!(scrollView)

        XCTAssertTrue(didZoom)
        subscription.dispose()
    }

    func testScrollToTop() {
        let scrollView = UIScrollView()
        var didScrollToTop = false

        let subscription = scrollView.rx.didScrollToTop.subscribe(onNext: { _ in
            didScrollToTop = true
        })

        XCTAssertFalse(didScrollToTop)

        scrollView.delegate!.scrollViewDidScrollToTop!(scrollView)

        XCTAssertTrue(didScrollToTop)
        subscription.dispose()
    }

    func testDidEndScrollingAnimation() {
        var completed = false

        autoreleasepool {
            let scrollView = UIScrollView()
            var didEndScrollingAnimation = false
            
            _ = scrollView.rx.didEndScrollingAnimation.subscribe(onNext: { _ in
                didEndScrollingAnimation = true
            }, onCompleted: {
                completed = true
            })
            
            XCTAssertFalse(didEndScrollingAnimation)
            
            scrollView.delegate!.scrollViewDidEndScrollingAnimation!(scrollView)
            
            XCTAssertTrue(didEndScrollingAnimation)
        }
        
        XCTAssertTrue(completed)
    }

    func testScrollViewWillBeginZooming() {
        var completed = false

        autoreleasepool {
            let scrollView = UIScrollView()
            let zoomView = UIView()
            var results: [UIView?] = []

            _ = scrollView.rx.willBeginZooming.subscribe(onNext: { value in
                results.append(value)
            }, onCompleted: {
                completed = true
            })

            XCTAssertTrue(results.isEmpty)

            scrollView.delegate!.scrollViewWillBeginZooming!(scrollView, with: zoomView)
            scrollView.delegate!.scrollViewWillBeginZooming!(scrollView, with: nil)

            XCTAssertEqual(results[0], zoomView)
            XCTAssertNil(results[1])
        }

        XCTAssertTrue(completed)
    }

    func testScrollViewDidEndZooming() {
        var completed = false

        autoreleasepool {
            let scrollView = UIScrollView()
            let zoomView = UIView()
            var viewResults: [UIView?] = []
            var scaleResults: [CGFloat] = []

            _ = scrollView.rx.didEndZooming.subscribe(onNext: {
                let (view, scale) = $0
                viewResults.append(view)
                scaleResults.append(scale)
            }, onCompleted: {
                completed = true
            })

            XCTAssertTrue(viewResults.isEmpty)
            XCTAssertTrue(scaleResults.isEmpty)

            scrollView.delegate!.scrollViewDidEndZooming!(scrollView, with: zoomView, atScale: 0)
            scrollView.delegate!.scrollViewDidEndZooming!(scrollView, with: nil, atScale: 2)

            XCTAssertEqual(viewResults[0], zoomView)
            XCTAssertNil(viewResults[1])
            XCTAssertEqual(scaleResults, [0, 2])
        }

        XCTAssertTrue(completed)
    }
}

@objc final class MockScrollViewDelegate
    : NSObject
    , UIScrollViewDelegate {}

extension UIScrollViewTests {
    func testSetDelegateUsesWeakReference() {
        let scrollView = UIScrollView()

        var delegateDeallocated = false

        autoreleasepool {
            let delegate = MockScrollViewDelegate()
            _ = scrollView.rx.setDelegate(delegate)

            _ = delegate.rx.deallocated.subscribe(onNext: { _ in
                delegateDeallocated = true
            })

            XCTAssert(delegateDeallocated == false)
        }
        XCTAssert(delegateDeallocated == true)
    }
}

#endif
