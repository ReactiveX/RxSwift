//
//  SimpleTableViewExampleSectionedViewController.swift
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

class SimpleTableViewExampleSectionedViewController
    : ViewController
    , UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let dataSource = self.dataSource

        let items = Observable.just([
            SectionModel(model: "First section", items: [
                    1.0,
                    2.0,
                    3.0
                ]),
            SectionModel(model: "Second section", items: [
                    1.0,
                    2.0,
                    3.0
                ]),
            SectionModel(model: "Third section", items: [
                    1.0,
                    2.0,
                    3.0
                ])
            ])

        dataSource.configureCell = { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
            return cell
        }

        items
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { indexPath, model in
                DefaultWireframe.presentAlert("Tapped `\(model)` @ \(indexPath)")
            })
            .addDisposableTo(disposeBag)

        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect.zero)
        label.text = dataSource[section].model
        return label
    }

    // to prevent swipe to delete behavior
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}
