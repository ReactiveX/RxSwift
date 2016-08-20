//
//  UITableView+Extensions.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 8/20/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import UIKit

extension UITableView {
    func hideEmptyCells() {
        self.tableFooterView = UIView(frame: .zero)
    }
}
