//
//  RxScrollViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

// Please take a look at `DelegateProxyType.swift`
public class RxScrollViewDelegateProxy : Delegate
                                       , UIScrollViewDelegate
                                       , DelegateProxyType {
    public typealias ContentOffsetObserver = ObserverOf<CGPoint>
    public typealias ContentOffsetDisposeKey = Bag<ContentOffsetObserver>.KeyType

    public typealias WillBeginDeceleratingObserver = ObserverOf<()>
    public typealias WillBeginDeceleratingDisposeKey = Bag<WillBeginDeceleratingObserver>.KeyType
    
    public typealias DidEndDeceleratingObserver = ObserverOf<()>
    public typealias DidEndDeceleratingDisposeKey = Bag<DidEndDeceleratingObserver>.KeyType
    
    var contentOffsetObservers: Bag<ContentOffsetObserver>?
    var willBeginDeceleratingObservers: Bag<WillBeginDeceleratingObserver>?
    var didEndDeceleratingObservers: Bag<DidEndDeceleratingObserver>?
    
    let scrollView: UIScrollView
    
    var scrollViewDelegate: UIScrollViewDelegate? = nil
    
    public init(view: UIView) {
        contentOffsetObservers = Bag()
        self.scrollView = view as! UIScrollView
    }
    
    // registering / unregistering observers
    
    public func addContentOffsetObserver(observer: ContentOffsetObserver) -> ContentOffsetDisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        if contentOffsetObservers == nil {
            contentOffsetObservers = Bag()
        }
        return contentOffsetObservers!.put(observer)
    }
    
    public func removeContentOffsetObserver(key: ContentOffsetDisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = contentOffsetObservers?.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }

    public func addWillBeginDeceleratingObserver(observer: WillBeginDeceleratingObserver) -> WillBeginDeceleratingDisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        if willBeginDeceleratingObservers == nil {
            willBeginDeceleratingObservers = Bag()
        }
        return willBeginDeceleratingObservers!.put(observer)
    }
    
    public func removeWillBeginDeceleratingObserver(key: WillBeginDeceleratingDisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = willBeginDeceleratingObservers?.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
    
    public func addDidEndDeceleratingObserver(observer: DidEndDeceleratingObserver) -> DidEndDeceleratingDisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        if didEndDeceleratingObservers == nil {
            didEndDeceleratingObservers = Bag()
        }
        return didEndDeceleratingObservers!.put(observer)
    }
    
    public func removeDidEndDeceleratingObserver(key: DidEndDeceleratingDisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = didEndDeceleratingObservers?.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
    
    // delegate methods
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        dispatchNext(scrollView.contentOffset, contentOffsetObservers)
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        dispatchNext((), willBeginDeceleratingObservers)
        scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        dispatchNext((), didEndDeceleratingObservers)
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    // delegate proxy
    
    public class func getProxyForView(view: UIView) -> Self? {
        MainScheduler.ensureExecutingOnScheduler()
        
        let scrollView = view as! UIScrollView
        
        if scrollView.delegate == nil {
            return nil
        }
        
        return castOptionalOrFatalError(scrollView.delegate)
    }
    
    public class func setProxyToView(view: UIView, proxy: AnyObject) {
        let scrollView = view as! UIScrollView
        
        let delegate: UIScrollViewDelegate = castOrFatalError(proxy)
        scrollView.delegate = delegate
    }
    
    public class func createProxyForView(view: UIView) -> Self {
        let scrollView = view as! UIScrollView
        
        return castOrFatalError(scrollView.rx_createDelegateProxy())
    }
    
    public func setDelegate(delegate: AnyObject?) {
        scrollViewDelegate = castOptionalOrFatalError(delegate)
        
        // refresh cached delegate respondsTo tables {
        assert(self.scrollView.delegate === self)
        self.scrollView.delegate = nil
        self.scrollView.delegate = self
        // }
    }
    
    public func getDelegate() -> AnyObject? {
        return self.scrollViewDelegate
    }
    
    override public func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return self.scrollViewDelegate
    }
    
    override public func respondsToSelector(aSelector: Selector) -> Bool {
        return super.respondsToSelector(aSelector) || (self.scrollViewDelegate?.respondsToSelector(aSelector) ?? false)
    }
    
    // dispose
    
    override public func dispose() {
        super.dispose()
        
        assert(self.scrollView.delegate === self || self.scrollView.delegate == nil)
        self.scrollView.delegate = nil
    }
    
    override public var isDisposable: Bool {
        get {
            return super.isDisposable
                && self.scrollViewDelegate == nil
                && self.contentOffsetObservers?.count ?? 0 == 0
                && self.willBeginDeceleratingObservers?.count ?? 0 == 0
                && self.didEndDeceleratingObservers?.count ?? 0 == 0
        }
    }
    
    deinit {
        if !isDisposable {
            handleVoidObserverResult(failure(rxError(RxCocoaError.InvalidOperation, "Something went wrong. Deallocating scroll delegate while there are still subscribed observers means that some subscription was left undisposed.")))
        }
    }
}