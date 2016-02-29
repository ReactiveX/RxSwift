//
//  SimpleValidationViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

let minimalUsernameLength = 5
let minimalPasswordLength = 5

class SimpleValidationViewController : ViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidOutlet: UILabel!

    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidOutlet: UILabel!

    @IBOutlet weak var doSomethingOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameValidOutlet.text = "Username has to be at least \(minimalUsernameLength) characters"
        passwordValidOutlet.text = "Password has to be at least \(minimalPasswordLength) characters"

        let usernameValid = usernameOutlet.rx_text
            .map { $0.characters.count >= minimalUsernameLength }
            .shareReplay(1) // without this map would be executed once for each binding, rx is stateless by default

        let passwordValid = passwordOutlet.rx_text
            .map { $0.characters.count >= minimalPasswordLength }
            .shareReplay(1)

        let everythingValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .shareReplay(1)

        usernameValid
            .bindTo(passwordOutlet.rx_enabled)
            .addDisposableTo(disposeBag)

        usernameValid
            .bindTo(usernameValidOutlet.rx_hidden)
            .addDisposableTo(disposeBag)

        passwordValid
            .bindTo(passwordValidOutlet.rx_hidden)
            .addDisposableTo(disposeBag)

        everythingValid
            .bindTo(doSomethingOutlet.rx_enabled)
            .addDisposableTo(disposeBag)

        doSomethingOutlet.rx_tap
            .subscribeNext { [weak self] in self?.showAlert() }
            .addDisposableTo(disposeBag)
    }

    func showAlert() {
        let alertView = UIAlertView(
            title: "RxExample",
            message: "This is wonderful",
            delegate: nil,
            cancelButtonTitle: "OK"
        )

        alertView.show()
    }

}