//
//  RxTableViewDelegateType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/26/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public protocol RxTableViewDelegateType : RxScrollViewDelegateType {
    
    // Display customization
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    @availability(iOS, introduced=6.0)
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    @availability(iOS, introduced=6.0)
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    @availability(iOS, introduced=6.0)
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    @availability(iOS, introduced=6.0)
    func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    @availability(iOS, introduced=6.0)
    func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
    
    // Variable height support
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    
    // Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
    // If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
    @availability(iOS, introduced=7.0)
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    @availability(iOS, introduced=7.0)
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    @availability(iOS, introduced=7.0)
    func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    
    // Section header & footer information. Views are preferred over title should you decide to provide both
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? // custom view for header. will be adjusted to default or specified header height
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? // custom view for footer. will be adjusted to default or specified footer height
    
    // Accessories (disclosures).
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
    
    // Selection
    
    // -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
    // Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
    @availability(iOS, introduced=6.0)
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
    @availability(iOS, introduced=6.0)
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath)
    @availability(iOS, introduced=6.0)
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath)
    
    // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    @availability(iOS, introduced=3.0)
    func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    // Called after the user changes the selection.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    @availability(iOS, introduced=3.0)
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    
    // Editing
    
    // Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    @availability(iOS, introduced=3.0)
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String!
    @availability(iOS, introduced=8.0)
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
    
    // Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool
    
    // The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath)
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath)
    
    // Moving/reordering
    
    // Allows customization of the target row for a particular row as it is being moved/reordered
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath
    
    // Indentation
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int // return 'depth' of row for hierarchies
    
    // Copy/Paste.  All three methods must be implemented by the delegate.
    
    @availability(iOS, introduced=5.0)
    func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool
    @availability(iOS, introduced=5.0)
    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool
    @availability(iOS, introduced=5.0)
    func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!)
}