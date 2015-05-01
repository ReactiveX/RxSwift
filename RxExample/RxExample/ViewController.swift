//
//  ViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ViewController: UIViewController {
#if DEBUG
    private let startResourceCount = RxSwift.resourceCount
#endif
    
    override func viewDidLoad() {
#if DEBUG
        println("Number of start resources = \(resourceCount)")
#endif
    }
    
    deinit {
#if DEBUG
        println("View controller disposed with \(resourceCount) resources")
    
        var numberOfResourcesThatShouldRemain = startResourceCount
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
            assert(numberOfResourcesThatShouldRemain >= resourceCount, "Resources weren't cleaned properly")
        })
#endif
    }
}