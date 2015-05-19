//
//  IntroductionExampleViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 5/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Cocoa
import AppKit

class IntroductionExampleViewController : ViewController {
    @IBOutlet var a: NSTextField!
    @IBOutlet var b: NSTextField!
    @IBOutlet var c: NSTextField!
    
    @IBOutlet var disposeButton: NSButton!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // c = a + b
        let sum = combineLatest(a.rx_text(), b.rx_text()) { (a, b) in
            return (a.toInt() ?? 0, b.toInt() ?? 0)
        }
        
        // bind result to UI
        sum
            >- map { (a, b) in
                return "\(a + b)"
            }
            >- c.rx_subscribeTextTo
            >- disposeBag.addDisposable
        
        // Also, tell it out loud
        let speech = NSSpeechSynthesizer()
        
        sum
            >- map { (a, b) in
                return "\(a) + \(b) = \(a + b)"
            }
            >- subscribeNext { result in
                if speech.speaking {
                    speech.stopSpeaking()
                }
                
                speech.startSpeakingString(result)
            }
            >- disposeBag.addDisposable
        
        disposeButton.rx_tap()
            >- subscribeNext { [unowned self] _ in
                println("Unbound everything")
                self.disposeBag.dispose()
            }
            >- disposeBag.addDisposable
    }
    
    deinit {
        disposeBag.dispose()
    }
}