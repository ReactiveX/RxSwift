//
//  UISearchBar+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

public extension Reactive where Base: UISearchBar {
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy<UISearchBar, UISearchBarDelegate> {
        RxSearchBarDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for `text` property.
    var text: ControlProperty<String?> {
        value
    }

    /// Reactive wrapper for `text` property.
    var value: ControlProperty<String?> {
        let source: Observable<String?> = Observable.deferred { [weak searchBar = self.base as UISearchBar] () -> Observable<String?> in
            let text = searchBar?.text

            let textDidChange = (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:textDidChange:))) ?? Observable.empty())
            let didEndEditing = (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarTextDidEndEditing(_:))) ?? Observable.empty())

            return Observable.merge(textDidChange, didEndEditing)
                .map { _ in searchBar?.text ?? "" }
                .startWith(text)
        }

        let bindingObserver = Binder(base) { (searchBar, text: String?) in
            searchBar.text = text
        }

        return ControlProperty(values: source, valueSink: bindingObserver)
    }

    /// Reactive wrapper for `selectedScopeButtonIndex` property.
    var selectedScopeButtonIndex: ControlProperty<Int> {
        let source: Observable<Int> = Observable.deferred { [weak source = self.base as UISearchBar] () -> Observable<Int> in
            let index = source?.selectedScopeButtonIndex ?? 0

            return (source?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:selectedScopeButtonIndexDidChange:))) ?? Observable.empty())
                .map { a in
                    try castOrThrow(Int.self, a[1])
                }
                .startWith(index)
        }

        let bindingObserver = Binder(base) { (searchBar, index: Int) in
            searchBar.selectedScopeButtonIndex = index
        }

        return ControlProperty(values: source, valueSink: bindingObserver)
    }

    #if os(iOS) || os(visionOS)
    /// Reactive wrapper for delegate method `searchBarCancelButtonClicked`.
    var cancelButtonClicked: ControlEvent<Void> {
        let source: Observable<Void> = delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:)))
            .map { _ in
                ()
            }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `searchBarBookmarkButtonClicked`.
    var bookmarkButtonClicked: ControlEvent<Void> {
        let source: Observable<Void> = delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarBookmarkButtonClicked(_:)))
            .map { _ in
                ()
            }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `searchBarResultsListButtonClicked`.
    var resultsListButtonClicked: ControlEvent<Void> {
        let source: Observable<Void> = delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarResultsListButtonClicked(_:)))
            .map { _ in
                ()
            }
        return ControlEvent(events: source)
    }
    #endif

    /// Reactive wrapper for delegate method `searchBarSearchButtonClicked`.
    var searchButtonClicked: ControlEvent<Void> {
        let source: Observable<Void> = delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarSearchButtonClicked(_:)))
            .map { _ in
                ()
            }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `searchBarTextDidBeginEditing`.
    var textDidBeginEditing: ControlEvent<Void> {
        let source: Observable<Void> = delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarTextDidBeginEditing(_:)))
            .map { _ in
                ()
            }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `searchBarTextDidEndEditing`.
    var textDidEndEditing: ControlEvent<Void> {
        let source: Observable<Void> = delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarTextDidEndEditing(_:)))
            .map { _ in
                ()
            }
        return ControlEvent(events: source)
    }

    /// Installs delegate as forwarding delegate on `delegate`.
    /// Delegate won't be retained.
    ///
    /// It enables using normal delegate mechanism with reactive delegate mechanism.
    ///
    /// - parameter delegate: Delegate object.
    /// - returns: Disposable object that can be used to unbind the delegate.
    func setDelegate(_ delegate: UISearchBarDelegate)
        -> Disposable
    {
        RxSearchBarDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
}

#endif
