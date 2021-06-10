//
//  AccessibilityCustomActionExampleViewController.swift
//  RxExample
//
//  Created by Evan Anger on 3/19/21.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

final class AccessibilityCustomActionExampleViewController: ViewController {
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let ca1 = UIAccessibilityCustomAction(name: "Here's a custom action number 1")
        let ca2 = UIAccessibilityCustomAction(name: "Then here's another custom actionnumber 2")
        
        ca1.rx.action
            .debug("Action 1")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        ca2.rx.action
            .debug("Action 2")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        textField.accessibilityCustomActions = [ca1, ca2]
    }
}
