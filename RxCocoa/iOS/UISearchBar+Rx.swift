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


#if os(iOS)
    extension UISearchBar {
        /// Factory method that enables subclasses to implement their own `delegate`.
        ///
        /// - returns: Instance of delegate proxy that wraps `delegate`.
        public func createRxDelegateProxy() -> RxSearchBarDelegateProxy {
            return RxSearchBarDelegateProxy(parentObject: self)
        }
        
    }
#endif

extension Reactive where Base: UISearchBar {

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy {
        return RxSearchBarDelegateProxy.proxyForObject(base)
    }

    /// Reactive wrapper for `text` property.
    public var text: ControlProperty<String?> {
        return value
    }
    
    /// Reactive wrapper for `text` property.
    public var value: ControlProperty<String?> {
        let source: Observable<String?> = Observable.deferred { [weak searchBar = self.base as UISearchBar] () -> Observable<String?> in
            let text = searchBar?.text
            
            return (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:textDidChange:))) ?? Observable.empty())
                    .map { a in
                        return a[1] as? String
                    }
                    .startWith(text)
        }

        let bindingObserver = UIBindingObserver(UIElement: self.base) { (searchBar, text: String?) in
            searchBar.text = text
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
    
    /// Reactive wrapper for `selectedScopeButtonIndex` property.
    public var selectedScopeButtonIndex: ControlProperty<Int> {
        let source: Observable<Int> = Observable.deferred { [weak source = self.base as UISearchBar] () -> Observable<Int> in
            let index = source?.selectedScopeButtonIndex ?? 0
            
            return (source?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:selectedScopeButtonIndexDidChange:))) ?? Observable.empty())
                .map { a in
                    return try castOrThrow(Int.self, a[1])
                }
                .startWith(index)
        }
        
        let bindingObserver = UIBindingObserver(UIElement: self.base) { (searchBar, index: Int) in
            searchBar.selectedScopeButtonIndex = index
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
    
#if os(iOS)
    /// Reactive wrapper for delegate method `searchBarCancelButtonClicked`.
    public var cancelButtonClicked: ControlEvent<Void> {
        let source: Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:)))
            .map { _ in
                return ()
            }
        return ControlEvent(events: source)
    }

	/// Reactive wrapper for delegate method `searchBarBookmarkButtonClicked`.
	public var bookmarkButtonClicked: ControlEvent<Void> {
		let source: Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarBookmarkButtonClicked(_:)))
			.map { _ in
				return ()
			}
		return ControlEvent(events: source)
	}

	/// Reactive wrapper for delegate method `searchBarResultsListButtonClicked`.
	public var resultsListButtonClicked: ControlEvent<Void> {
		let source: Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarResultsListButtonClicked(_:)))
			.map { _ in
				return ()
		}
		return ControlEvent(events: source)
	}
#endif
	
    /// Reactive wrapper for delegate method `searchBarSearchButtonClicked`.
    public var searchButtonClicked: ControlEvent<Void> {
        let source: Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarSearchButtonClicked(_:)))
            .map { _ in
                return ()
        }
        return ControlEvent(events: source)
    }
	
	/// Reactive wrapper for delegate method `searchBarTextDidBeginEditing`.
	public var textDidBeginEditing: ControlEvent<Void> {
		let source: Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarTextDidBeginEditing(_:)))
			.map { _ in
				return ()
		}
		return ControlEvent(events: source)
	}
	
	/// Reactive wrapper for delegate method `searchBarTextDidEndEditing`.
	public var textDidEndEditing: ControlEvent<Void> {
		let source: Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarTextDidEndEditing(_:)))
			.map { _ in
				return ()
		}
		return ControlEvent(events: source)
	}
	
}

#endif
