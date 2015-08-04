//
//  Calculator.swift
//  RxExample
//
//  Created by carlos on 4/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class CalculatorViewController: ViewController {
    
    @IBOutlet weak var lastSignLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var allClearButton: UIButton!
    @IBOutlet weak var changeSignButton: UIButton!
    @IBOutlet weak var moduleButton: UIButton!
   
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var equalButton: UIButton!
    
    @IBOutlet weak var dotButton: UIButton!
    
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    
    override func viewDidLoad() {
        
        let allClearButtonOble = allClearButton.rx_tap
        let changeSignButtonOble = changeSignButton.rx_tap
        let moduleButtonOble = moduleButton.rx_tap
        
        let divideButtonOble = divideButton.rx_tap
        let multiplyButtonOble = multiplyButton.rx_tap
        let minusButtonOble = minusButton.rx_tap
        let plusButtonOble = plusButton.rx_tap
        let equalButtonOble = equalButton.rx_tap
        
        let dotButtonOble = dotButton.rx_tap
        
        let zeroButtonOble = zeroButton.rx_tap
        let oneButtonOble = oneButton.rx_tap
        let twoButtonOble = twoButton.rx_tap
        let threeButtonOble = threeButton.rx_tap
        let fourButtonOble = fourButton.rx_tap
        let fiveButtonOble = fiveButton.rx_tap
        let sixButtonOble = sixButton.rx_tap
        let sevenButtonOble = sevenButton.rx_tap
        let eightButtonOble = eightButton.rx_tap
        let nineButtonOble = nineButton.rx_tap
        
        
        
    }
    
}
