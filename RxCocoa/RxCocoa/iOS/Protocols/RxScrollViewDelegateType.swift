//
//  RxScrollViewDelegateType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/26/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit

// Please take a look at `DelegateBridgeType.swift`
public protocol RxScrollViewDelegateType : class /*, UIScrollViewDelegate */ {
    
    func scrollViewDidScroll(scrollView: UIScrollView) // any offset changes
    
    @availability(iOS, introduced=3.2)
    func scrollViewDidZoom(scrollView: UIScrollView) // any zoom scale changes
    
    // called on start of dragging (may require some time and or distance to move)
    func scrollViewWillBeginDragging(scrollView: UIScrollView)
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    @availability(iOS, introduced=5.0)
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) // called on finger up as we are moving
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) // called when scroll view grinds to a halt
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? // return a view that will be scaled. if delegate returns nil, nothing happens
    @availability(iOS, introduced=3.2)
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) // called before the scroll view begins zooming its content
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) // scale between minimum and maximum. called after any 'bounce' animations
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool // return a yes if you want to scroll to the top. if not defined, assumes YES
    func scrollViewDidScrollToTop(scrollView: UIScrollView) // called when scrolling animation finished. may be called immediately if already at top
    
}
