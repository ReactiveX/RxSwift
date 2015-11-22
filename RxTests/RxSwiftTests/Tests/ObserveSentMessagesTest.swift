//
//  ObserveSentMessagesTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 11/21/15.
//
//

import Foundation
import XCTest

class ObserveSentMessages : RxTest {

}

@objc public class SendMessageTest: NSObject {
    var messages: [[AnyObject]]

    override init() {
        self.messages = []
        super.init()
    }

    @objc public func emptyMessage() -> Void {
        messages.append([])
    }

    @objc public func message_Int32(a: Int32) -> Void {
        messages.append([NSNumber(int: a)])
    }

    @objc public func message_Int64(a: Int64) -> Void {
        messages.append([NSNumber(longLong: a)])
    }

    @objc public func message_UInt32(a: UInt32) -> Void {
        messages.append([NSNumber(unsignedInt: a)])
    }

    @objc public func message_UInt64(a: UInt64) -> Void {
        messages.append([NSNumber(unsignedLongLong: a)])
    }

    @objc public func message_String(a: String) -> Void {
        messages.append([a])
    }

    @objc public func message_Object(a: AnyObject) -> Void {
        messages.append([a])
    }

    @objc public func message_allSupportedParameters(p1: Bool, p2: AnyObject, p3: Int, p4: Int32, p5: Int64, p6: UInt32, p7: UInt64, p8: (AnyObject) -> (AnyObject), p9: String) {

    }
}

extension ObserveSentMessages {
    func test() {
        let target = SendMessageTest()

        var messages = [[AnyObject]]()

        let d = target.rx_sentMessage("message_allSupportedParameters:p2:p3:p4:p5:p6:p7:p8:p9:").subscribeNext { n in
            messages.append(n)
        }

        target.message_allSupportedParameters(false, p2: SendMessageTest(), p3: -1, p4: -2, p5: 3, p6: 4, p7: 5, p8: { x in x.description }, p9: "last one :(")

        d.dispose()

        XCTAssertEqual(target.messages, messages)
    }
}