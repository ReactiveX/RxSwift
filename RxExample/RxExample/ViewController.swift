//
//  ViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

#if os(iOS)
    import UIKit
    typealias OSViewController = UIViewController
#elseif os(macOS)
    import Cocoa
    typealias OSViewController = NSViewController
#endif

class ViewController: OSViewController {
    var disposeBag = DisposeBag()
}
