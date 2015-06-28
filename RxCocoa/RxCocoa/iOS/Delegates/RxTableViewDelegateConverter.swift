//
//  RxTableViewDelegateConverter.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public class RxTableViewDelegateConverter : RxScrollViewDelegateConverter
                                          , RxTableViewDelegateType {
    
    unowned let tableViewDelegate: UITableViewDelegate
    let strongTableViewDelegate: UITableViewDelegate?
    
    public init(delegate: UITableViewDelegate, retainDelegate: Bool) {
    #if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
    #endif
        self.strongTableViewDelegate = retainDelegate ? delegate : nil
        
        self.tableViewDelegate = delegate
        super.init(delegate: delegate, retainDelegate: retainDelegate)
    }
    
    // Display customization
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate.tableView?(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }
    
    @availability(iOS, introduced=6.0)
    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableViewDelegate.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }
    
    @availability(iOS, introduced=6.0)
    public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        tableViewDelegate.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }
    
    @availability(iOS, introduced=6.0)
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate.tableView?(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath)
    }
    @availability(iOS, introduced=6.0)
    public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        tableViewDelegate.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }
    @availability(iOS, introduced=6.0)
    public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        tableViewDelegate.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }
    
    // Variable height support
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewDelegate.tableView?(tableView, heightForRowAtIndexPath: indexPath) ?? defaultHeight
    }
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewDelegate.tableView?(tableView, heightForHeaderInSection: section) ?? defaultHeight
    }
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableViewDelegate.tableView?(tableView, heightForFooterInSection: section) ?? defaultHeight
    }
    
    // Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
    // If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
    @availability(iOS, introduced=7.0)
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewDelegate.tableView?(tableView, estimatedHeightForRowAtIndexPath: indexPath) ?? defaultHeight
    }
    @availability(iOS, introduced=7.0)
    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return tableViewDelegate.tableView?(tableView, estimatedHeightForHeaderInSection: section) ?? defaultHeight
    }
    @availability(iOS, introduced=7.0)
    public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return tableViewDelegate.tableView?(tableView, estimatedHeightForFooterInSection: section) ?? defaultHeight
    }
    
    // Section header & footer information. Views are preferred over title should you decide to provide both
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? // custom view for header. will be adjusted to default or specified header height
    {
        return tableViewDelegate.tableView?(tableView, viewForHeaderInSection: section) ?? nil
    }
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? // custom view for footer. will be adjusted to default or specified footer height
    {
        return tableViewDelegate.tableView?(tableView, viewForFooterInSection: section) ?? nil
    }
    
    // Accessories (disclosures).
    
    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
    {
        tableViewDelegate.tableView?(tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
    }
    
    // Selection
    
    // -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
    // Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
    @availability(iOS, introduced=6.0)
    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableViewDelegate.tableView?(tableView, shouldHighlightRowAtIndexPath: indexPath) ?? true
    }
    @availability(iOS, introduced=6.0)
    public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate.tableView?(tableView, didHighlightRowAtIndexPath: indexPath)
    }
    @availability(iOS, introduced=6.0)
    public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate.tableView?(tableView, didUnhighlightRowAtIndexPath: indexPath)
    }
    
    // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
    public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return tableViewDelegate.tableView?(tableView, willSelectRowAtIndexPath: indexPath) ?? nil
    }
    @availability(iOS, introduced=3.0)
    public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return tableViewDelegate.tableView?(tableView, willDeselectRowAtIndexPath: indexPath) ?? nil
    }
    // Called after the user changes the selection.
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate.tableView?(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    @availability(iOS, introduced=3.0)
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate.tableView?(tableView, didDeselectRowAtIndexPath: indexPath)
    }
    
    // Editing
    
    // Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
    public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return tableViewDelegate.tableView?(tableView, editingStyleForRowAtIndexPath: indexPath) ?? .None
    }
    @availability(iOS, introduced=3.0)
    public func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return tableViewDelegate.tableView?(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath: indexPath) ?? nil
    }
    @availability(iOS, introduced=8.0)
    public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
    {
        return tableViewDelegate.tableView?(tableView, editActionsForRowAtIndexPath: indexPath) ?? nil
    }
    
    // Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
    public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableViewDelegate.tableView?(tableView, shouldIndentWhileEditingRowAtIndexPath: indexPath) ?? true
    }
    
    // The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
    public func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate.tableView?(tableView, willBeginEditingRowAtIndexPath: indexPath)
    }
    public func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate.tableView?(tableView, didEndEditingRowAtIndexPath: indexPath)
    }
    
    // Moving/reordering
    
    // Allows customization of the target row for a particular row as it is being moved/reordered
    public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        return tableViewDelegate.tableView?(tableView, targetIndexPathForMoveFromRowAtIndexPath: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) ?? proposedDestinationIndexPath
    }
    
    // Indentation
    
    public func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int // return 'depth' of row for hierarchies
    {
        return tableViewDelegate.tableView?(tableView, indentationLevelForRowAtIndexPath: indexPath) ?? 0
    }
    
    // Copy/Paste.  All three methods must be implemented by the delegate.
    
    @availability(iOS, introduced=5.0)
    public func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableViewDelegate.tableView?(tableView, shouldShowMenuForRowAtIndexPath: indexPath) ?? false
    }
    @availability(iOS, introduced=5.0)
    public func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool {
        return tableViewDelegate.tableView?(tableView, canPerformAction: action, forRowAtIndexPath: indexPath, withSender: sender) ?? false
    }
    @availability(iOS, introduced=5.0)
    public func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        tableViewDelegate.tableView?(tableView, performAction: action, forRowAtIndexPath: indexPath, withSender: sender)
    }
    
    deinit {
    #if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
    #endif
    }
}