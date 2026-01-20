//
//  CustomPickerViewAdapterExampleViewController.swift
//  RxExample
//
//  Created by Sergey Shulga on 12/07/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class CustomPickerViewAdapterExampleViewController: ViewController {
    @IBOutlet var pickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.just([[1, 2, 3], [5, 8, 13], [21, 34]])
            .bind(to: pickerView.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)

        pickerView.rx.modelSelected(Int.self)
            .subscribe(onNext: { models in
                print(models)
            })
            .disposed(by: disposeBag)
    }
}

final class PickerViewViewAdapter:
    NSObject,
    UIPickerViewDataSource,
    UIPickerViewDelegate,
    RxPickerViewDataSourceType,
    SectionedViewDataSourceType
{
    typealias Element = [[CustomStringConvertible]]
    private var items: [[CustomStringConvertible]] = []

    func model(at indexPath: IndexPath) throws -> Any {
        items[indexPath.section][indexPath.row]
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        items.count
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        items[component].count
    }

    func pickerView(_: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing _: UIView?) -> UIView {
        let label = UILabel()
        label.text = items[component][row].description
        label.textColor = UIColor.orange
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }

    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        Binder(self) { adapter, items in
            adapter.items = items
            pickerView.reloadAllComponents()
        }.on(observedEvent)
    }
}
