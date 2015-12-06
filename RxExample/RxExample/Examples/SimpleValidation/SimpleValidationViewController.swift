//
//  SimpleValidation.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

let mininalUsernameLength = 5
let mininalPasswordLength = 5

class SimpleValidationViewController : ViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var usernameValid: UILabel!

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordValid: UILabel!

    @IBOutlet weak var doSomething: UIButton!

    func showAlert() {
        DefaultWireframe.sharedInstance.promptFor("Something wonderful has been done", cancelAction: "OK", actions: [])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let usernameValid = username.rx_text
            .map { $0.characters.count >= mininalUsernameLength }
            .shareReplay(1) // without this map would be executed once for each binding, rx is stateless by default

        let passwordValid = password.rx_text
            .map { $0.characters.count >= mininalPasswordLength }
            .shareReplay(1)

        let everythingValid = combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .shareReplay(1)

        

        usernameValid
            .bindTo(password.rx_enabled)
            .addDisposableTo(disposeBag)

        everythingValid
            .bindTo(doSomething.rx_enabled)
            .addDisposableTo(disposeBag)

        doSomething.rx_tap
            .subscribeNext(showAlert)
            .addDisposableTo(disposeBag)
    }
}