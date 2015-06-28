//
//  RxScrollViewDelegateConverter.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/26/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public class RxScrollViewDelegateConverter : RxScrollViewDelegateType
                                           , DelegateConverterType {
    unowned let scrollViewDelegate: UIScrollViewDelegate
    let strongScrollViewDelegate: UIScrollViewDelegate?
    
    public init(delegate: UIScrollViewDelegate, retainDelegate: Bool) {
    #if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
    #endif
        self.strongScrollViewDelegate = retainDelegate ? delegate : nil
        
        self.scrollViewDelegate = delegate
    }
    
    // converter
    
    public var targetDelegate: NSObjectProtocol? {
        get {
            return scrollViewDelegate as? NSObjectProtocol
        }
    }
    
    // delegate
 
    public func scrollViewDidScroll(scrollView: UIScrollView) // any offset changes
    {
        scrollViewDelegate.scrollViewDidScroll?(scrollView)
    }
    
    @availability(iOS, introduced=3.2)
    public func scrollViewDidZoom(scrollView: UIScrollView) // any zoom scale changes
    {
        scrollViewDelegate.scrollViewDidZoom?(scrollView)
    }
    
    // called on start of dragging (may require some time and or distance to move)
    public func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        scrollViewDelegate.scrollViewWillBeginDragging?(scrollView)
    }
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    @availability(iOS, introduced=5.0)
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        scrollViewDelegate.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        scrollViewDelegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) // called on finger up as we are moving
    {
        scrollViewDelegate.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) // called when scroll view grinds to a halt
    {
        scrollViewDelegate.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    {
        scrollViewDelegate.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? // return a view that will be scaled. if delegate returns nil, nothing happens
    {
        return scrollViewDelegate.viewForZoomingInScrollView?(scrollView) ?? nil
    }
    
    @availability(iOS, introduced=3.2)
    public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) // called before the scroll view begins zooming its content
    {
        scrollViewDelegate.scrollViewWillBeginZooming?(scrollView, withView: view)
    }
    
    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) // scale between minimum and maximum. called after any 'bounce' animations
    {
        scrollViewDelegate.scrollViewDidEndZooming?(scrollView, withView: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool // return a yes if you want to scroll to the top. if not defined, assumes YES
    {
        return scrollViewDelegate.scrollViewShouldScrollToTop?(scrollView) ?? false
    }
    
    public func scrollViewDidScrollToTop(scrollView: UIScrollView) // called when scrolling animation finished. may be called immediately if already at top
    {
        scrollViewDelegate.scrollViewDidScrollToTop?(scrollView)
    }
    
    deinit {
    #if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
    #endif
    }
}