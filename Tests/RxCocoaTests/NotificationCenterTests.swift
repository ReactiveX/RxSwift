//
//  NotificationCenterTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

import class Foundation.NotificationCenter
import class Foundation.NSObject
import struct Foundation.Notification

class NSNotificationCenterTests : RxTest {
    func testNotificationCenterWithoutObject() {
        let notificationCenter = NotificationCenter()
        
        var numberOfNotifications = 0

        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: nil)
        
        XCTAssertTrue(numberOfNotifications == 0)
        
        let subscription = notificationCenter.rx.notification(Notification.Name(rawValue: "testNotification"), object: nil)
            .subscribe(onNext: { n in
                numberOfNotifications += 1
            })

        XCTAssertTrue(numberOfNotifications == 0)
        
        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: nil)
        
        XCTAssertTrue(numberOfNotifications == 1)
        
        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: NSObject())
        
        XCTAssertTrue(numberOfNotifications == 2)
        
        subscription.dispose()

        XCTAssertTrue(numberOfNotifications == 2)
        
        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: nil)

        XCTAssertTrue(numberOfNotifications == 2)
    }
    
    func testNotificationCenterWithObject() {
        let notificationCenter = NotificationCenter()
        
        var numberOfNotifications = 0
        
        let targetObject = NSObject()
        
        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: targetObject)
        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: nil)
        
        XCTAssertTrue(numberOfNotifications == 0)
        
        let subscription = notificationCenter.rx.notification(Notification.Name(rawValue: "testNotification"), object: targetObject)
            .subscribe(onNext: { n in
                numberOfNotifications += 1
            })
        
        XCTAssertTrue(numberOfNotifications == 0)
        
        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: targetObject)
        
        XCTAssertTrue(numberOfNotifications == 1)
        
        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: nil)
        
        XCTAssertTrue(numberOfNotifications == 1)

        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: NSObject())
        
        XCTAssertTrue(numberOfNotifications == 1)
        
        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: targetObject)
        
        XCTAssertTrue(numberOfNotifications == 2)
        
        subscription.dispose()
        
        XCTAssertTrue(numberOfNotifications == 2)
        
        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: targetObject)
        
        XCTAssertTrue(numberOfNotifications == 2)
    }
}
