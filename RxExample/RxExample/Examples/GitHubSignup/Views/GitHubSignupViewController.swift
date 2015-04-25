//
//  GitHubSignupViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class GitHubSignupViewController : ViewController {
    weak var username: UITextField!
    weak var password: UITextField!
    weak var repeatedPassword: UITextField!
    weak var signup: UIButton!
    
    var disposeBag = DisposeBag()
    
    var $ = (
        API: GitHubAPI(
            dataScheduler: MainScheduler.sharedInstance,
            URLSession: NSURLSession.sharedSession()
        )
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}