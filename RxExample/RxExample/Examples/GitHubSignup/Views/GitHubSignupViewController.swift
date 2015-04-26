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

class ValidationService {
    let API: GitHubAPI
    
    init (API: GitHubAPI) {
        self.API = API
    }
    
    // validation
    
    let minPasswordCount = 5
    
    func validateUsername(username: String) -> Observable<(valid: Bool?, message: String?)> {
        if count(username) == 0 {
            return returnElement((false, nil))
        }
        
        let loadingValue = (valid: nil as Bool?, message: "Checking availabilty ..." as String?)
        
        return API.usernameAvailable(username) >- map { available in
            if available {
                return (true, "Username valid")
            }
            else {
                return (false, "Username already taken")
            }
        } >- prefixWith(loadingValue)
    }
    
    func validatePassword(password: String) -> (valid: Bool?, message: String?) {
        let numberOfCharacters = count(password)
        if numberOfCharacters == 0 {
            return (false, nil)
        }
        
        if numberOfCharacters < minPasswordCount {
            return (false, "Password must be at least \(minPasswordCount) characters")
        }
        
        return (true, "Password acceptable")
    }
    
    func validateRepeatedPassword(password: String, repeatedPassword: String) -> (valid: Bool?, message: String?) {
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
    @IBOutlet weak var usernameValidatingOutlet: UIActivityIndicatorView!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    
    var disposeBag = DisposeBag()
    
    let API = GitHubAPI(
        dataScheduler: MainScheduler.sharedInstance,
        URLSession: NSURLSession.sharedSession()
    )
    
    func bindValidationResultToUI(source: Observable<(valid: Bool?, message: String?)>,
        activityIndicator: UIActivityIndicatorView!,
        validationErrorLabel: UILabel) {
        source >- subscribeNext { [unowned self] v in
            println("next\(v)")
            if let activityIndicator = activityIndicator {
                if v.valid == nil {
                    self.view.addSubview(activityIndicator)
                }
                else {
                    activityIndicator.removeFromSuperview()
                }
            
                //activityIndicator.hidden = v.valid != nil
            }
            
            let validationColor: UIColor
            
            if let valid = v.valid {
                validationColor = valid ? okColor : errorColor
            }
            else {
               validationColor = UIColor.grayColor()
            }
            
            validationErrorLabel.textColor = validationColor
            validationErrorLabel.text = v.message ?? ""
            validationErrorLabel.setNeedsLayout()
            //println("let \(validationErrorLabel)")
        } >- disposeBag.addDisposable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.disposeBag = DisposeBag()
        
        let validationService = ValidationService(API: API)
     
        let usernameValidation = usernameOutlet.rx_text() >- map { username in
            return validationService.validateUsername(username)
        } >- switchLatest >- variable
        
        let passwordValidation = passwordOutlet.rx_text() >- map { password in
            return validationService.validatePassword(password)
        } >- variable
        
        let repeatPasswordValidation = combineLatest(
            passwordOutlet.rx_text(),
            repeatedPasswordOutlet.rx_text()
        ) { (password, repeatedPassword) in
            return validationService.validateRepeatedPassword(password, repeatedPassword: repeatedPassword)
        } >- variable
        
        let signupEnabled = combineLatest(
            usernameValidation,
            passwordValidation,
            repeatPasswordValidation) { un, p, pr in
            return (un.valid ?? false) && (p.valid ?? false) && (pr.valid ?? false)
        }
        
        bindValidationResultToUI(
            usernameValidation,
            activityIndicator: self.usernameValidatingOutlet,
            validationErrorLabel: self.usernameValidationOutlet
        )

        bindValidationResultToUI(
            passwordValidation,
            activityIndicator: nil,
            validationErrorLabel: self.passwordValidationOutlet
        )

        bindValidationResultToUI(
            repeatPasswordValidation,
            activityIndicator: nil,
            validationErrorLabel: self.repeatedPasswordValidationOutlet
        )
        
        signupEnabled >- subscribeNext { [unowned self] valid  in
            self.signupOutlet.enabled = valid
            self.signupOutlet.alpha = valid ? 1.0 : 0.5
        } >- disposeBag.addDisposable
    }
}