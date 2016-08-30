//
//  UITextView+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 7/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

    
    
extension UITextView : RxTextInput {
    
    /**
    Factory method that enables subclasses to implement their own `rx_delegate`.
    
    - returns: Instance of delegate proxy that wraps `delegate`.
    */
    public override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxTextViewDelegateProxy(parentObject: self)
    }
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        let source: Observable<String> = Observable.deferred { [weak self] in
            let text = self?.text ?? ""
            
            let textChanged = self?.textStorage
                // This project uses text storage notifications because
                // that's the only way to catch autocorrect changes
                // in all cases. Other suggestions are welcome.
                .rx_didProcessEditingRangeChangeInLength
                // This observe on is here because text storage
                // will emit event while process is not completely done,
                // so rebinding a value will cause an exception to be thrown.
                .observeOn(MainScheduler.asyncInstance)
                .map { _ in
                    return self?.textStorage.string ?? ""
                }
                ?? Observable.empty()
            
            return textChanged
                .startWith(text)
        }

        let bindingObserver = UIBindingObserver(UIElement: self) { (textView, text: String) in
            // This check is important because setting text value always clears control state
            // including marked text selection which is imporant for proper input 
            // when IME input method is used.
            if textView.text != text {
                textView.text = text
            }
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }

    /**
     Reactive wrapper for `delegate` message.
    */
    public var rx_didBeginEditing: ControlEvent<()> {
       return ControlEvent<()>(events: self.rx_delegate.observe(#selector(UITextViewDelegate.textViewDidBeginEditing(_:)))
            .map { a in
                return ()
            })
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    public var rx_didEndEditing: ControlEvent<()> {
        return ControlEvent<()>(events: self.rx_delegate.observe(#selector(UITextViewDelegate.textViewDidEndEditing(_:)))
            .map { a in
                return ()
            })
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    public var rx_didChange: ControlEvent<()> {
        return ControlEvent<()>(events: self.rx_delegate.observe(#selector(UITextViewDelegate.textViewDidChange(_:)))
            .map { a in
                return ()
            })
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    public var rx_didChangeSelection: ControlEvent<()> {
        return ControlEvent<()>(events: self.rx_delegate.observe(#selector(UITextViewDelegate.textViewDidChangeSelection(_:)))
            .map { a in
                return ()
            })
    }

}

#endif
