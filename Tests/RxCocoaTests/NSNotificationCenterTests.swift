//
//  NSNotificationCenterTests.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

class NSNotificationCenterTests : RxTest {
    func testNotificationCenterWithoutObject() {
        let notificationCenter = NSNotificationCenter()
        
        var numberOfNotifications = 0

        notificationCenter.postNotificationName("testNotification", object: nil)
        
        XCTAssertTrue(numberOfNotifications == 0)
        
        let subscription = notificationCenter.rx_notification("testNotification", object: nil)
            .subscribeNext { n in
            numberOfNotifications += 1
        }

        XCTAssertTrue(numberOfNotifications == 0)
        
        notificationCenter.postNotificationName("testNotification", object: nil)
        
        XCTAssertTrue(numberOfNotifications == 1)
        
        notificationCenter.postNotificationName("testNotification", object: NSObject())
        
        XCTAssertTrue(numberOfNotifications == 2)
        
        subscription.dispose()

        XCTAssertTrue(numberOfNotifications == 2)
        
        notificationCenter.postNotificationName("testNotification", object: nil)

        XCTAssertTrue(numberOfNotifications == 2)
    }
    
    func testNotificationCenterWithObject() {
        let notificationCenter = NSNotificationCenter()
        
        var numberOfNotifications = 0
        
        let targetObject = NSObject()
        
        notificationCenter.postNotificationName("testNotification", object: targetObject)
        notificationCenter.postNotificationName("testNotification", object: nil)
        
        XCTAssertTrue(numberOfNotifications == 0)
        
        let subscription = notificationCenter.rx_notification("testNotification", object: targetObject)
            .subscribeNext { n in
                numberOfNotifications += 1
        }
        
        XCTAssertTrue(numberOfNotifications == 0)
        
        notificationCenter.postNotificationName("testNotification", object: targetObject)
        
        XCTAssertTrue(numberOfNotifications == 1)
        
        notificationCenter.postNotificationName("testNotification", object: nil)
        
        XCTAssertTrue(numberOfNotifications == 1)

        notificationCenter.postNotificationName("testNotification", object: NSObject())
        
        XCTAssertTrue(numberOfNotifications == 1)
        
        notificationCenter.postNotificationName("testNotification", object: targetObject)
        
        XCTAssertTrue(numberOfNotifications == 2)
        
        subscription.dispose()
        
        XCTAssertTrue(numberOfNotifications == 2)
        
        notificationCenter.postNotificationName("testNotification", object: targetObject)
        
        XCTAssertTrue(numberOfNotifications == 2)
    }
}