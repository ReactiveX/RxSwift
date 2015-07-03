//
//  RxCollectionViewDelegateConverter.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public class RxCollectionViewDelegateConverter : RxScrollViewDelegateConverter
                                               , RxCollectionViewDelegateType {

    unowned let collectionViewDelegate: UICollectionViewDelegate
    let strongCollectionViewDelegate: UICollectionViewDelegate?
    
    public init(delegate: UICollectionViewDelegate, retainDelegate: Bool) {
    #if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
    #endif
        self.strongCollectionViewDelegate = retainDelegate ? delegate : nil
        
        self.collectionViewDelegate = delegate
        super.init(delegate: delegate, retainDelegate: retainDelegate)
    }
    
    public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return collectionViewDelegate.collectionView?(collectionView, shouldHighlightItemAtIndexPath: indexPath) ?? true
    }
    
    public func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        collectionViewDelegate.collectionView?(collectionView, didHighlightItemAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        collectionViewDelegate.collectionView?(collectionView, didUnhighlightItemAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return collectionViewDelegate.collectionView?(collectionView, shouldSelectItemAtIndexPath: indexPath) ?? true
    }
    
    public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return collectionViewDelegate.collectionView?(collectionView, shouldDeselectItemAtIndexPath: indexPath) ?? true
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionViewDelegate.collectionView?(collectionView, didSelectItemAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        collectionViewDelegate.collectionView?(collectionView, didDeselectItemAtIndexPath: indexPath)
    }
    
    @availability(iOS, introduced=8.0)
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        collectionViewDelegate.collectionView?(collectionView, willDisplayCell: cell, forItemAtIndexPath: indexPath)
    }
    
    @availability(iOS, introduced=8.0)
    public func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        collectionViewDelegate.collectionView?(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, atIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        collectionViewDelegate.collectionView?(collectionView, didEndDisplayingCell: cell, forItemAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        collectionViewDelegate.collectionView?(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, atIndexPath: indexPath)
    }
    
    // These methods provide support for copy/paste actions on cells.
    // All three should be implemented if any are.
    public func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return collectionViewDelegate.collectionView?(collectionView, shouldShowMenuForItemAtIndexPath: indexPath) ?? false
    }
    
    public func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) -> Bool {
        return collectionViewDelegate.collectionView?(collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender) ?? false
    }
    public func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        collectionViewDelegate.collectionView?(collectionView, performAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    // support for custom transition layout
    public func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout! {
        return collectionViewDelegate.collectionView?(collectionView, transitionLayoutForOldLayout: fromLayout, newLayout: toLayout)
    }
 
    deinit {
    #if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
    #endif
    }
}