//
//  UIPopoverPresentationController+RxTests.swift
//  Tests
//
//  Created by Vladimir Kushelkov on 01/04/2018.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import RxCocoa
import UIKit
import XCTest
import RxSwift

final class UIPopoverPresentationControllerTests : RxTest {
    
}

@available(iOS 8.0, *)
extension UIPopoverPresentationControllerTests {
    func testDidDismissPopoverPresentationController() {
        var didDismissed = false
        var completed = false
        
        autoreleasepool {
            let popoverController = UIPopoverPresentationController(presentedViewController: UIViewController(),
                                                                    presenting: UIViewController())
            
            XCTAssertNotEqual(popoverController.presentedViewController, popoverController.presentingViewController)

            _ = popoverController.rx.didDismiss
                .subscribe(onNext: { _ in
                    didDismissed = true
                }, onCompleted: {
                    completed = true
                })

            popoverController.delegate!.popoverPresentationControllerDidDismissPopover!(popoverController)
        }
        
        XCTAssertTrue(didDismissed)
        XCTAssertTrue(completed)
    }
    
    func testPrepareForPresentationPopoverPresentationController() {
        var preparedForPresentation = false
        var completed = false
        
        autoreleasepool {
            let popoverController = UIPopoverPresentationController(presentedViewController: UIViewController(),
                                                                    presenting: UIViewController())
            
            XCTAssertNotEqual(popoverController.presentedViewController, popoverController.presentingViewController)
            
            _ = popoverController.rx.prepareForPresentation
                .subscribe(onNext: { _ in
                    preparedForPresentation = true
                }, onCompleted: {
                    completed = true
                })
            
            popoverController.delegate!.prepareForPopoverPresentation!(popoverController)
        }
        
        XCTAssertTrue(preparedForPresentation)
        XCTAssertTrue(completed)
    }
    
    func testWillRepositionPopoverPresentationController() {
        var completed = false
        
        autoreleasepool {
            let firstView = UIView(frame: CGRect(x: 1, y: 2, width: 3, height: 4))
            let secondView = UIView(frame: CGRect(x: 5, y: 6, width: 7, height: 8))
            let popoverController = UIPopoverPresentationController(presentedViewController: UIViewController(),
                                                                    presenting: UIViewController())
            
            var argView = firstView
            var argRect = firstView.frame
            
            var rect: CGRect? = nil
            var view: UIView? = nil

            _ = popoverController.rx.willReposition
                .subscribe(onNext: { args in
                    rect = args.toRect.pointee
                    view = args.inView.pointee

                    args.toRect.pointee = secondView.frame
                    args.inView.pointee = secondView
                }, onCompleted: {
                    completed = true
                })
            
            XCTAssertNil(rect)
            XCTAssertNil(view)
            
            XCTAssertEqual(argRect, firstView.frame)
            XCTAssertEqual(argView, firstView)

            popoverController.delegate!.popoverPresentationController!(popoverController,
                                                                       willRepositionPopoverTo: &argRect,
                                                                       in: &argView)
            
            XCTAssertEqual(rect, firstView.frame)
            XCTAssertEqual(view, firstView)
            
            XCTAssertEqual(argRect, secondView.frame)
            XCTAssertEqual(argView, secondView)
        }
        
        XCTAssertTrue(completed)
    }
}

#endif
