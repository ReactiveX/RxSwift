//
//  GitHubSignupViewController2.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

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
                username: usernameOutlet.rx_text.asDriver(),
                password: passwordOutlet.rx_text.asDriver(),
                repeatedPassword: repeatedPasswordOutlet.rx_text.asDriver(),
                loginTaps: signupOutlet.rx_tap.asDriver()
            ),
            dependency: (
                API: GitHubDefaultAPI.sharedAPI,
                validationService: GitHubDefaultValidationService.sharedValidationService,
                wireframe: DefaultWireframe.sharedInstance
            )
        )

        // bind results to  {
        viewModel.signupEnabled
            .driveNext { [weak self] valid  in
                self?.signupOutlet.enabled = valid
                self?.signupOutlet.alpha = valid ? 1.0 : 0.5
            }
            .addDisposableTo(disposeBag)

        viewModel.validatedUsername
            .drive(usernameValidationOutlet.ex_validationResult)
            .addDisposableTo(disposeBag)

        viewModel.validatedPassword
            .drive(passwordValidationOutlet.ex_validationResult)
            .addDisposableTo(disposeBag)

        viewModel.validatedPasswordRepeated
            .drive(repeatedPasswordValidationOutlet.ex_validationResult)
            .addDisposableTo(disposeBag)

        viewModel.signingIn
            .drive(signingUpOulet.rx_animating)
            .addDisposableTo(disposeBag)

        viewModel.signedIn
            .driveNext { signedIn in
                print("User signed in \(signedIn)")
            }
            .addDisposableTo(disposeBag)
        //}

        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx_event
            .subscribeNext { [weak self] _ in
                self?.view.endEditing(true)
            }
            .addDisposableTo(disposeBag)
        view.addGestureRecognizer(tapBackground)
    }
   
    // This is one of the reasons why it's a good idea for disposal to be detached from allocations.
    // If resources weren't disposed before view controller is being deallocated, signup alert view
    // could be presented on top of the wrong screen or could crash your app if it was being presented 
    // while navigation stack is popping.
    
    // This will work well with UINavigationController, but has an assumption that view controller will
    // never be added as a child view controller. If we didn't recreate the dispose bag here,
    // then our resources would never be properly released.
    override func willMoveToParentViewController(parent: UIViewController?) {
        if let parent = parent {
            assert(parent.isKindOfClass(UINavigationController), "Please read comments")
        }
        else {
            self.disposeBag = DisposeBag()
        }
    }

}