//
//  UIPickerView+RxTests.swift
//  Tests
//
//  Created by Segii Shulga on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import XCTest


final class UIPickerViewTests: RxTest {
    
    func testTableView_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIPickerView = { UIPickerView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        
        ensureEventDeallocated(createView) { (view: UIPickerView) in view.rx.itemSelected }
    }

    func testPickerView_itemSelected() {
        let pickerView = UIPickerView()
        let row = 0
        let component = 0
        var result: (row: Int, component: Int)?
        
        autoreleasepool {
            _ = pickerView.rx.itemSelected.subscribe(onNext: { (element) in
                result = element
            })
            pickerView.delegate!.pickerView!(pickerView,
                didSelectRow: row,
                inComponent: component)
        }
        XCTAssertEqual(result?.row, row)
        XCTAssertEqual(result?.component, component)
    }
}
