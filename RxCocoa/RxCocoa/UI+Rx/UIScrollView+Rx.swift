//
//  UIScrollView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

public class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    public typealias ScrollViewObserver = ObserverOf<CGPoint>
    
    public typealias ScrollViewDisposeKey = Bag<ScrollViewObserver>.KeyType
    
    var scrollViewObsevers: Bag<ScrollViewObserver>
    
    override public init() {
        scrollViewObsevers = Bag()
    }
    
    public func addScrollViewObserver(observer: ScrollViewObserver) -> ScrollViewDisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        
        return scrollViewObsevers.put(observer)
    }
    
    public func removeScrollViewObserver(key: ScrollViewDisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = scrollViewObsevers.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let event = Event.Next(Box(scrollView.contentOffset))
        
        handleObserverResult(dispatch(event, scrollViewObsevers.all))
    }
    
    deinit {
        if scrollViewObsevers.count > 0 {
            handleVoidObserverResult(.Error(rxError(RxCocoaError.InvalidOperation, "Something went wrong. Deallocating scroll delegate while there are still subscribed observers means that some subscription was left undisposed.")))
        }
    }
}

extension UIScrollView {
    func rx_createDelegate() -> ScrollViewDelegate {
        return ScrollViewDelegate()
    }
    
    public func rx_observableContentOffset() -> Observable<CGPoint> {
        _ = rx_checkScrollViewDelegate()
        
        return AnonymousObservable { observer in
            var maybeDelegate = self.rx_checkScrollViewDelegate()
            
            if maybeDelegate == nil {
                let delegate = self.rx_createDelegate() as ScrollViewDelegate
                maybeDelegate = delegate
                self.delegate = maybeDelegate
            }
            
            let delegate = maybeDelegate!
            
            let key = delegate.addScrollViewObserver(observer)
            
            return success(AnonymousDisposable {
                _ = self.rx_checkScrollViewDelegate()
                
                delegate.removeScrollViewObserver(key)
                
                if delegate.scrollViewObsevers.count == 0 {
                    self.delegate = nil
                }
            })
        }
    }
    
    // private
    private func rx_checkScrollViewDelegate() -> ScrollViewDelegate? {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.delegate == nil {
            return nil
        }
        
        let maybeDelegate = self.delegate as? ScrollViewDelegate
        
        if maybeDelegate == nil {
            rxFatalError("View already has incompatible delegate set. To use rx observable (for now) please remove earlier delegate registration.")
        }
        
        return maybeDelegate!
    }
}