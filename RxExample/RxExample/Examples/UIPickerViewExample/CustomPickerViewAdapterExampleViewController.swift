//
//  CustomPickerViewAdapterExampleViewController.swift
//  RxExample
//
//  Created by Sergey Shulga on 12/07/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

final class CustomPickerViewAdapterExampleViewController: ViewController {
    @IBOutlet weak var pickerView1: UIPickerView!
    @IBOutlet weak var pickerView2: UIPickerView!
    @IBOutlet weak var pickerView3: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.just([[1, 2, 3], [5, 8, 13], [21, 34]])
            .bind(to: pickerView1.rx.items(adapter: CustomStringPickerViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([[1, 2, 3], [5, 8, 13], [21, 34]])
            .bind(to: pickerView2.rx.items(adapter: CustomAttributedStringPickerViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([[1, 2, 3], [5, 8, 13], [21, 34]])
            .bind(to: pickerView3.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
    }
}

final class CustomStringPickerViewAdapter
    : NSObject
    , UIPickerViewDataSource
    , UIPickerViewDelegate
    , RxPickerViewDataSourceType {
    typealias Element = [[CustomStringConvertible]]
    private var items: [[CustomStringConvertible]] = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[component][row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
            }.on(observedEvent)
    }
}

final class CustomAttributedStringPickerViewAdapter
    : NSObject
    , UIPickerViewDataSource
    , UIPickerViewDelegate
    , RxPickerViewDataSourceType {
    typealias Element = [[CustomStringConvertible]]
    private var items: [[CustomStringConvertible]] = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: items[component][row].description,
                                  attributes: [
                                    NSForegroundColorAttributeName: UIColor.cyan,
                                    NSUnderlineStyleAttributeName: NSUnderlineStyle.styleDouble.rawValue
            ])
    }
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
            }.on(observedEvent)
    }
}

final class PickerViewViewAdapter
    : NSObject
    , UIPickerViewDataSource
    , UIPickerViewDelegate
    , RxPickerViewDataSourceType {
    typealias Element = [[CustomStringConvertible]]
    private var items: [[CustomStringConvertible]] = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = items[component][row].description
        label.textColor = UIColor.orange
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
            }.on(observedEvent)
    }
}


