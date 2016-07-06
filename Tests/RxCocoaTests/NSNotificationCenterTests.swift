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
        let notificationCenter = NotificationCenter()
        
        var numberOfNotifications = 0

        notificationCenter.post(name: Notification.Name(rawValue: "testNotification"), object: nil)
        
        XCTAssertTrue(numberOfNotifications == 0)
        
        let subscription = notificationCenter.rx_notification(Notification.Name(rawValue: "testNotification"), object: nil)
            .subscribeNext { n in
            numberOfNotifications += 1
        }

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
        
        let subscription = notificationCenter.rx_notification(Notification.Name(rawValue: "testNotification"), object: targetObject)
            .subscribeNext { n in
                numberOfNotifications += 1
        }
        
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
