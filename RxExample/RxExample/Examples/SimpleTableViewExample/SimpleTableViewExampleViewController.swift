//
//  SimpleTableViewExampleViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class SimpleTableViewExampleViewController : ViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let items = Observable.just([
            "First Item",
            "Second Item",
            "Third Item"
        ])

        items
            .bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
            }
            .addDisposableTo(disposeBag)


        tableView
            .rx_modelSelected(String)
            .subscribeNext { value in
                DefaultWireframe.presentAlert("Tapped `\(value)`")
            }
            .addDisposableTo(disposeBag)

        tableView
            .rx_itemAccessoryButtonTapped
            .subscribeNext { indexPath in
                DefaultWireframe.presentAlert("Tapped Detail @ \(indexPath.section),\(indexPath.row)")
            }
            .addDisposableTo(disposeBag)

    }
}