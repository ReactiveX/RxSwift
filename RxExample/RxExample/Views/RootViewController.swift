//
//  RootViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/6/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit

public class RootViewController : UITableViewController {
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.performSegueWithIdentifier("ShowWikipediaSearch", sender: nil)
    }
}