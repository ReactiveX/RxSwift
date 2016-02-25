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
    
    /**
     Factory method that enables subclasses to implement their own `rx_delegate`.
     
     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createDelegateProxy() -> RxSearchBarDelegateProxy {
      return RxSearchBarDelegateProxy(parentObject: self)
    }
    
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
            
            return (self?.rx_delegate.observe("searchBar:textDidChange:") ?? Observable.empty())
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
     Reactive wrapper for `searchBarSearchButtonClicked:` delegate event.
     */
    public var rx_searchButtonClicked: ControlEvent<UISearchBar> {
        let source: Observable<UISearchBar> = Observable.deferred { [weak self] () -> Observable<UISearchBar> in
            return (self?.rx_delegate.observe("searchBarSearchButtonClicked:") ?? Observable.empty())
                .flatMap { a -> Observable<UISearchBar> in
                    let result = a.first.flatMap { $0 as? UISearchBar }.flatMap { Observable.just($0) }
                    return result ?? Observable.empty()
            }
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `searchBarCancelButtonClicked:` delegate event.
     */
    public var rx_cancelButtonClicked: ControlEvent<UISearchBar> {
        let source: Observable<UISearchBar> = Observable.deferred { [weak self] () -> Observable<UISearchBar> in
            return (self?.rx_delegate.observe("searchBarCancelButtonClicked:") ?? Observable.empty())
                .flatMap { a -> Observable<UISearchBar> in
                    let result = a.first.flatMap { $0 as? UISearchBar }.flatMap { Observable.just($0) }
                    return result ?? Observable.empty()
            }
        }
      
        return ControlEvent(events: source)
    }
  }
  
#endif
