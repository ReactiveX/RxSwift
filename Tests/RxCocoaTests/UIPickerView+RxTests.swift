//
//  UIPickerView+RxTests.swift
//  Rx
//
//  Created by Segii Shulga on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import XCTest


class UIPickerViewTests: RxTest {
    
    func testTableView_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIPickerView = { UIPickerView(frame: CGRectMake(0, 0, 1, 1)) }
        
        ensureEventDeallocated(createView) { (view: UIPickerView) in view.rx_itemSelected }
    }

    func testPickerView_itemSelected() {
        let pickerView = UIPickerView()
        let row = 0
        let component = 0
        var result: (row: Int, component: Int)?
        
        autoreleasepool {
            _ = pickerView.rx_itemSelected.subscribeNext { (element) in
                result = element
            }
            pickerView.delegate!.pickerView!(pickerView,
                didSelectRow: row,
                inComponent: component)
        }
        XCTAssertEqual(result?.row, row)
        XCTAssertEqual(result?.component, component)
    }
}
