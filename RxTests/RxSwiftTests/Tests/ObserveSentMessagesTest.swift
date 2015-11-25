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

    @objc public func message_allSupportedParameters(p1: AnyObject, p2: AnyClass, p3: (Int) -> (Int), p4: Int8, p5: Int16, p6: Int32, p7: Int64, p8: UInt8, p9: UInt16, p10: UInt32, p11: UInt64, p12: Float, p13: Double, p14: UnsafePointer<Int8>, p15: UnsafeMutablePointer<Int8>) {
        messages.append([p1, p2, p3 as! AnyObject, NSNumber(char: p4), NSNumber(short: p5), NSNumber(int: p6), NSNumber(longLong: p7), NSNumber(unsignedChar: p8), NSNumber(unsignedShort: p9), NSNumber(unsignedInt: p10), NSNumber(unsignedLongLong: p11), NSNumber(float: p12), NSNumber(double: p13), NSValue(pointer: p14), NSValue(pointer: p15)])
    }
}

extension ObserveSentMessages {
    func testBasic() {
        let target = SendMessageTest()

        var messages = [[AnyObject]]()
        let d = target.rx_sentMessage("message_allSupportedParameters:p2:p3:p4:p5:p6:p7:p8:p9:p10:p11:p12:p13:p14:p15:").subscribeNext { n in
            messages.append(n)
        }

        let str: UnsafePointer<Int8> = ("123" as NSString).UTF8String
        let unsafeStr: UnsafeMutablePointer<Int8> = UnsafeMutablePointer.init(str)
        let obj = SendMessageTest()
        target.message_allSupportedParameters(obj, p2: obj.dynamicType, p3: { x in x}, p4: -2, p5: -3, p6: -4, p7: -5,
            p8: 1, p9: 2, p10: 3, p11: 4, p12: 1.0, p13: 2.0, p14: str, p15: unsafeStr)

        d.dispose()

        XCTAssertEqual(target.messages, messages)
    }
}