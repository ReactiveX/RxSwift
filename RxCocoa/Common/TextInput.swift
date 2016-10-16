//
//  TextInput.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if !RX_NO_MODULE
    import RxSwift
#endif

#if os(iOS) || os(tvOS)
    import UIKit

    /**
    Represents text input with reactive extensions.
    */
    public struct TextInput<Base: UITextInput> {
        /**
         Base text input to extend.
        */
        public let base: Base

        /**
         Reactive wrapper for `text` property.
        */
        public let text: ControlProperty<String?>

        /**
         Initializes new text input.
         
         - parameter base: Base object.
         - parameter text: Textual control property.
        */
        public init(base: Base, text: ControlProperty<String?>) {
            self.base = base
            self.text = text
        }
    }

    extension Reactive where Base: UITextField {
        /**
         Reactive text input.
        */
        public var textInput: TextInput<UITextField> {
            return TextInput(base: base, text: self.text)
        }
    }

    extension Reactive where Base: UITextView {
        /**
         Reactive text input.
         */
        public var textInput: TextInput<UITextView> {
            return TextInput(base: base, text: self.text)
        }
    }

    /**
     Represents text input with reactive extensions.
     */
    @available(*, deprecated, renamed: "TextInput")
    public protocol RxTextInput : UITextInput {
        @available(*, deprecated, renamed: "rx.textInput.text")
        var rx_text: ControlProperty<String?> { get }
    }

    extension UITextField : RxTextInput {
        @available(*, deprecated, renamed: "rx.textInput.text")
        public var rx_text: ControlProperty<String?> {
            return self.rx.text
        }
    }

    extension UITextView : RxTextInput {
        @available(*, deprecated, renamed: "rx.textInput.text")
        public var rx_text: ControlProperty<String?> {
            return self.rx.text
        }
    }


#endif

#if os(OSX)
    import Cocoa

    /**
     Represents text input with reactive extensions.
     */
    public struct TextInput<Base: NSTextInput> {
        /**
         Base text input to extend.
         */
        public let base: Base

        /**
         Reactive wrapper for `text` property.
         */
        public let text: ControlProperty<String>

        /**
         Initializes new text input.

         - parameter base: Base object.
         - parameter text: Textual control property.
         */
        public init(base: Base, text: ControlProperty<String>) {
            self.base = base
            self.text = text
        }
    }

    extension Reactive where Base: NSTextField {
        /**
         Reactive text input.
         */
        public var textInput: TextInput<NSTextField> {
            return TextInput(base: base, text: self.text)
        }
    }

    /**
    Represents text input with reactive extensions.
    */
    @available(*, deprecated, renamed: "TextInput")
    public protocol RxTextInput : NSTextInput {
        
        /**
         Reactive wrapper for `text` property.
        */
        @available(*, deprecated, renamed: "rx.textInput.text")
        var rx_text: ControlProperty<String> { get }
    }

    @available(*, deprecated)
    extension NSTextField : RxTextInput {
        /**
         Reactive wrapper for `text` property.
         */
        @available(*, deprecated, renamed: "rx.textInput.text")
        public var rx_text: ControlProperty<String> {
            return self.rx.text
        }
    }

#endif


