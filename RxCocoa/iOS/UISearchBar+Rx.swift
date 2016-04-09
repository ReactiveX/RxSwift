//
//  UISearchBar+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit



extension UISearchBar {
    
#if os(iOS)
    /**
     Factory method that enables subclasses to implement their own `rx_delegate`.
     
     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createDelegateProxy() -> RxSearchBarDelegateProxy {
        return RxSearchBarDelegateProxy(parentObject: self)
    }
#endif
    
    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxSearchBarDelegateProxy.self, self)
    }
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        let source: Observable<String> = Observable.deferred { [weak self] () -> Observable<String> in
            let text = self?.text ?? ""
            
            return (self?.rx_delegate.observe(#selector(UISearchBarDelegate.searchBar(_:textDidChange:))) ?? Observable.empty())
                    .map { a in
                        return a[1] as? String ?? ""
                    }
                    .startWith(text)
        }

        let bindingObserver = UIBindingObserver(UIElement: self) { (searchBar, text: String) in
            searchBar.text = text
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
    
    /**
    Reactive wrapper for `selectedScopeButtonIndex` property.
    */
    public var rx_selectedScopeButtonIndex: ControlProperty<Int> {
        let source: Observable<Int> = Observable.deferred { [weak self] () -> Observable<Int> in
            let index = self?.selectedScopeButtonIndex ?? 0
            
            return (self?.rx_delegate.observe(#selector(UISearchBarDelegate.searchBar(_:selectedScopeButtonIndexDidChange:))) ?? Observable.empty())
                .map { a in
                    return try castOrThrow(Int.self, a[1])
                }
                .startWith(index)
        }
        
        let bindingObserver = UIBindingObserver(UIElement: self) { (searchBar, index: Int) in
            searchBar.selectedScopeButtonIndex = index
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
    
#if os(iOS)
    /**
    Reactive wrapper for delegate method `searchBarCancelButtonClicked`.
    */
    public var rx_cancelButtonClicked: ControlEvent<Void> {
        let source: Observable<Void> = rx_delegate.observe(#selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:)))
            .map { _ in
                return ()
            }
        return ControlEvent(events: source)
    }
#endif
    
    /**
     Reactive wrapper for delegate method `searchBarSearchButtonClicked`.
     */
    public var rx_searchButtonClicked: ControlEvent<Void> {
        let source: Observable<Void> = rx_delegate.observe(#selector(UISearchBarDelegate.searchBarSearchButtonClicked(_:)))
            .map { _ in
                return ()
        }
        return ControlEvent(events: source)
    }
}

#endif
