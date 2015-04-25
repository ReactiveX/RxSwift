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
    override func viewDidLoad() {
#if DEBUG
        if resourceCount != 1 {
            println("Number of resources = \(resourceCount)")
            assert(resourceCount == 1)
        }
#endif
    }
    
    deinit {
#if DEBUG
        println("View controller disposed with \(resourceCount) resournces")
#endif
    }
}