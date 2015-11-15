//
//  GitHubSignupViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

typealias ValidationResult = (valid: Bool?, message: String?)
typealias ValidationObservable = Observable<ValidationResult>

// Two way binding operator between control property and variable, that's all it takes {

infix operator <-> {
}

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
}

// }


class ValidationService {
    let API: GitHubAPI
    
    init (API: GitHubAPI) {
        self.API = API
    }
    
    // validation
    
    let minPasswordCount = 5
    
    func validateUsername(username: String) -> ValidationObservable {
        if username.characters.count == 0 {
            return just((false, nil))
        }
        
        // this obviously won't be
        if username.rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) != nil {
            return just((false, "Username can only contain numbers or digits"))
        }
        
        let loadingValue = (valid: nil as Bool?, message: "Checking availabilty ..." as String?)
        
        return API.usernameAvailable(username)
            .map { available in
                if available {
                    return (true, "Username available")
                }
                else {
                    return (false, "Username already taken")
                }
            }
            .startWith(loadingValue)
    }
    
    func validatePassword(password: String) -> ValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0 {
            return (false, nil)
        }
        
        if numberOfCharacters < minPasswordCount {
            return (false, "Password must be at least \(minPasswordCount) characters")
        }
        
        return (true, "Password acceptable")
    }
    
    func validateRepeatedPassword(password: String, repeatedPassword: String) -> ValidationResult {
        if repeatedPassword.characters.count == 0 {
            return (false, nil)
        }
        
        if repeatedPassword == password {
            return (true, "Password repeated")
        }
        else {
            return (false, "Password different")
        }
    }
}

class GitHubSignupViewController : ViewController {
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingUpOulet: UIActivityIndicatorView!

    let username = Variable("")
    let password = Variable("")
    let repeatedPassword = Variable("")

    struct ValidationColors {
        static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
        static let errorColor = UIColor.redColor()
    }
    
    var disposeBag = DisposeBag()
    
    let API = GitHubAPI(
        dataScheduler: MainScheduler.sharedInstance,
        URLSession: NSURLSession.sharedSession()
    )
    
    func bindValidationResultToUI(source: Observable<(valid: Bool?, message: String?)>,
        validationErrorLabel: UILabel) {
        source
            .subscribeNext { v in
                let validationColor: UIColor
                
                if let valid = v.valid {
                    validationColor = valid ? ValidationColors.okColor : ValidationColors.errorColor
                } else {
                   validationColor = UIColor.grayColor()
                }
                
                validationErrorLabel.textColor = validationColor
                validationErrorLabel.text = v.message ?? ""
            }
            .addDisposableTo(disposeBag)
    }
    
    func dismissKeyboard(gr: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapBackground = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
        view.addGestureRecognizer(tapBackground)
        
        let API = self.API
        
        let validationService = ValidationService(API: API)

        // bind UI values to variables {
        usernameOutlet.rx_text <-> username
        passwordOutlet.rx_text <-> password
        repeatedPasswordOutlet.rx_text <-> repeatedPassword
        // }

        let signupSampler = signupOutlet.rx_tap
        
        let usernameValidation = username
            .flatMapLatest { username in
                return validationService.validateUsername(username)
            }
            .shareReplay(1)

        let passwordValidation = password
            .map { password in
                return validationService.validatePassword(password)
            }
            .shareReplay(1)

        let repeatPasswordValidation = combineLatest(password, repeatedPassword) { (password, repeatedPassword) in
                validationService.validateRepeatedPassword(password, repeatedPassword: repeatedPassword)
            }
            .shareReplay(1)
        
        let signingProcess = combineLatest(username, password) { ($0, $1) }
            .sampleLatest(signupSampler)
            .flatMapLatest { (username, password) in
                return API.signup(username, password: password)
            }
            .startWith(SignupState.InitialState)
            .shareReplay(1)
        
        let signupEnabled = combineLatest(
            usernameValidation,
            passwordValidation,
            repeatPasswordValidation,
            signingProcess
        ) { username, password, repeatPassword, signingState in
            return (username.valid ?? false) &&
                   (password.valid ?? false) &&
                   (repeatPassword.valid ?? false) &&
                   signingState != SignupState.SigningUp
        }
        
        bindValidationResultToUI(
            usernameValidation,
            validationErrorLabel: self.usernameValidationOutlet
        )

        bindValidationResultToUI(
            passwordValidation,
            validationErrorLabel: self.passwordValidationOutlet
        )

        bindValidationResultToUI(
            repeatPasswordValidation,
            validationErrorLabel: self.repeatedPasswordValidationOutlet
        )
        
        signupEnabled
            .subscribeNext { [unowned self] valid  in
                self.signupOutlet.enabled = valid
                self.signupOutlet.alpha = valid ? 1.0 : 0.5
            }
            .addDisposableTo(disposeBag)
        
        
        signingProcess
            .subscribeNext { [unowned self] signingResult in
                switch signingResult {
                case .SigningUp:
                    self.signingUpOulet.hidden = false
                case .SignedUp(let signed):
                    self.signingUpOulet.hidden = true

                    if signed {
                        showAlert("Mock signed up to GitHub")
                    }
                    else {
                        showAlert("Mock signed up failed")
                    }
                default:
                    self.signingUpOulet.hidden = true
                }
            }
            .addDisposableTo(disposeBag)

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