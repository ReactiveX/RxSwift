//
//  RxTextInput.swift
//  Rx
//
//  Created by Krunoslav Zaher on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
    import UIKit

    /**
    Represents text input with reactive extensions.
    */
    public protocol RxTextInput : UITextInput {

        /**
         Reactive wrapper for `text` property.
        */
        var rx_text: ControlProperty<String> { get }
    }

    extension UITextField : RxTextInput {
        public var rx_text: ControlProperty<String> {
            return self.rx.text
        }
    }

    extension UITextView : RxTextInput {
        public var rx_text: ControlProperty<String> {
            return self.rx.text
        }
    }

#endif

#if os(OSX)
    import Cocoa

    /**
    Represents text input with reactive extensions.
    */
    public protocol RxTextInput : NSTextInput {
        
        /**
         Reactive wrapper for `text` property.
        */
        var rx_text: ControlProperty<String> { get }
    }

    extension NSTextField : RxTextInput {
        public var rx_text: ControlProperty<String> {
            return self.rx.text
        }
    }

#endif


