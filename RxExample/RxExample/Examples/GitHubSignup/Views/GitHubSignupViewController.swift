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

let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
let errorColor = UIColor.redColor()

typealias ValidationResult = (valid: Bool?, message: String?)
typealias ValidationObservable = Observable<ValidationResult>

class ValidationService {
    let API: GitHubAPI
    
    init (API: GitHubAPI) {
        self.API = API
    }
    
    // validation
    
    let minPasswordCount = 5
    
    func validateUsername(username: String) -> Observable<ValidationResult> {
        if count(username) == 0 {
            return returnElement((false, nil))
        }
        
        // this obviously won't be
        if username.rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) != nil {
            return returnElement((false, "Username can only contain numbers or digits"))
        }
        
        let loadingValue = (valid: nil as Bool?, message: "Checking availabilty ..." as String?)
        
        return API.usernameAvailable(username)
            >- map { available in
                if available {
                    return (true, "Username available")
                }
                else {
                    return (false, "Username already taken")
                }
            }
            >- startWith(loadingValue)
    }
    
    func validatePassword(password: String) -> ValidationResult {
        let numberOfCharacters = count(password)
        if numberOfCharacters == 0 {
            return (false, nil)
        }
        
        if numberOfCharacters < minPasswordCount {
            return (false, "Password must be at least \(minPasswordCount) characters")
        }
        
        return (true, "Password acceptable")
    }
    
    func validateRepeatedPassword(password: String, repeatedPassword: String) -> ValidationResult {
        if count(repeatedPassword) == 0 {
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
    
    var disposeBag = DisposeBag()
    
    let API = GitHubAPI(
        dataScheduler: MainScheduler.sharedInstance,
        URLSession: NSURLSession.sharedSession()
    )
    
    func bindValidationResultToUI(source: Observable<(valid: Bool?, message: String?)>,
        validationErrorLabel: UILabel) {
        source >- subscribeNext { [unowned self] v in
            let validationColor: UIColor
            
            if let valid = v.valid {
                validationColor = valid ? okColor : errorColor
            }
            else {
               validationColor = UIColor.grayColor()
            }
            
            validationErrorLabel.textColor = validationColor
            validationErrorLabel.text = v.message ?? ""
        } >- disposeBag.addDisposable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.disposeBag = DisposeBag()
        
        let API = self.API
        
        let validationService = ValidationService(API: API)
     
        let username = usernameOutlet.rx_text
        let password = passwordOutlet.rx_text
        let repeatPassword = repeatedPasswordOutlet.rx_text
        let signupSampler = self.signupOutlet.rx_tap
        
        let usernameValidation = username
            >- map { username in
                return validationService.validateUsername(username)
            }
            >- switchLatest
            >- variable
        
        let passwordValidation = password
            >- map { password in
                return validationService.validatePassword(password)
            }
            >- variable
        
        let repeatPasswordValidation = combineLatest(password, repeatPassword) { (password, repeatedPassword) in
                validationService.validateRepeatedPassword(password, repeatedPassword: repeatedPassword)
            }
            >- variable
        
        let signingProcess = combineLatest(username, password) { ($0, $1) }
            >- sampleLatest(signupSampler)
            >- map { (username, password) in
                return API.signup(username, password: password)
            }
            >- switchLatest
            >- startWith(.InitialState)
            >- variable
        
        let signupEnabled = combineLatest(
            usernameValidation,
            passwordValidation,
            repeatPasswordValidation,
            signingProcess
        ) { un, p, pr, signingState in
            return (un.valid ?? false) && (p.valid ?? false) && (pr.valid ?? false) && signingState != SignupState.SigningUp
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
            >- subscribeNext { [unowned self] valid  in
                self.signupOutlet.enabled = valid
                self.signupOutlet.alpha = valid ? 1.0 : 0.5
            }
            >- disposeBag.addDisposable
        
        
        signingProcess
            >- subscribeNext { [unowned self] signingResult in
                switch signingResult {
                case .SigningUp:
                    self.signingUpOulet.hidden = false
                case .SignedUp(let signed):
                    self.signingUpOulet.hidden = true
                    
                    let controller: UIAlertController
                    
                    if signed {
                        controller = UIAlertController(title: "GitHub", message: "Mock signed up to GitHub", preferredStyle: .Alert)
                    }
                    else {
                        controller = UIAlertController(title: "GitHub", message: "Mock signed up failed", preferredStyle: .Alert)
                    }
                    
                    controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    self.presentViewController(controller, animated: true, completion: nil)
                default:
                    self.signingUpOulet.hidden = true
                }
            }
            >- disposeBag.addDisposable
    }
   
    // This is one of the reasons why it's a good idea for disposal to be detached from allocations.
    // If resources weren't disposed before view controller is being deallocated, signup alert view
    // could be presented on top of wrong screen or crash your app if it was being presented while
    // navigation stack is popping.
    // This will work well with UINavigationController, but has an assumption that view controller will
    // never be readded as a child view controller.
    // It it was readded UI wouldn't be bound anymore.
    override func willMoveToParentViewController(parent: UIViewController?) {
        if let parent = parent {
            assert(parent.isKindOfClass(UINavigationController), "Please read comments")
        }
        else {
            self.disposeBag = DisposeBag()
        }
    }
}