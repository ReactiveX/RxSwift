//
//  GitHubSignupViewController2.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GitHubSignupViewController2 : ViewController {
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingUpOulet: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = GithubSignupViewModel2(
            input: (
                username: usernameOutlet.rx.text.orEmpty.asDriver(),
                password: passwordOutlet.rx.text.orEmpty.asDriver(),
                repeatedPassword: repeatedPasswordOutlet.rx.text.orEmpty.asDriver(),
                loginTaps: signupOutlet.rx.tap.asSignal()
            ),
            dependency: (
                API: GitHubDefaultAPI.sharedAPI,
                validationService: GitHubDefaultValidationService.sharedValidationService,
                wireframe: DefaultWireframe.shared
            )
        )

        // bind results to  {
        viewModel.signupEnabled
            .drive(onNext: { [weak self] valid  in
                self?.signupOutlet.isEnabled = valid
                self?.signupOutlet.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)

        viewModel.validatedUsername
            .drive(usernameValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)

        viewModel.validatedPassword
            .drive(passwordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)

        viewModel.validatedPasswordRepeated
            .drive(repeatedPasswordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)

        viewModel.signingIn
            .drive(signingUpOulet.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.signedIn
            .drive(onNext: { signedIn in
                print("User signed in \(signedIn)")
            })
            .disposed(by: disposeBag)
        //}

        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapBackground)
    }
}
