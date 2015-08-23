//
//  ViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

#if os(iOS)
    import UIKit
    typealias OSViewController = UIViewController
#elseif os(OSX)
    import Cocoa
    typealias OSViewController = NSViewController
#endif

class ViewController: OSViewController {
#if TRACE_RESOURCES
    #if !RX_NO_MODULE
    private let startResourceCount = RxSwift.resourceCount
    #else
    private let startResourceCount = resourceCount
    #endif
#endif
    
    override func viewDidLoad() {
#if TRACE_RESOURCES
        print("Number of start resources = \(resourceCount)")
#endif
    }
    
    deinit {
#if TRACE_RESOURCES
        print("View controller disposed with \(resourceCount) resources")
    
        let numberOfResourcesThatShouldRemain = startResourceCount
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
            assert(resourceCount <= numberOfResourcesThatShouldRemain, "Resources weren't cleaned properly")
        })
#endif
    }
}