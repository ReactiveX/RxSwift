//
//  SimpleTableViewExampleSectionedViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class SimpleTableViewExampleSectionedViewController:
    ViewController,
    UITableViewDelegate
{
    @IBOutlet var tableView: UITableView!

    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>(
        configureCell: { _, tv, indexPath, element in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
            return cell
        },
        titleForHeaderInSection: { dataSource, sectionIndex in
            dataSource[sectionIndex].model
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let dataSource = dataSource

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

        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .itemSelected
            .map { indexPath in
                (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                DefaultWireframe.presentAlert("Tapped `\(pair.1)` @ \(pair.0)")
            })
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }

    // to prevent swipe to delete behavior
    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        40
    }
}
