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
    @IBOutlet var slider: NSSlider!
    @IBOutlet var sliderValue: NSTextField!
    
    @IBOutlet var disposeButton: NSButton!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showAlert("After you close this, prepare for a loud sound ...")

        // c = a + b
        let sum = combineLatest(a.rx_text, b.rx_text) { (a: String, b: String) -> (Int, Int) in
            return (Int(a) ?? 0, Int(b) ?? 0)
        }
        
        // bind result to UI
        sum
            .map { (a, b) in
                return "\(a + b)"
            }
            .bindTo(c.rx_text)
            .addDisposableTo(disposeBag)
        
        // Also, tell it out loud
        let speech = NSSpeechSynthesizer()
        
        sum
            .map { (a, b) in
                return "\(a) + \(b) = \(a + b)"
            }
            .subscribeNext { result in
                if speech.speaking {
                    speech.stopSpeaking()
                }
                
                speech.startSpeakingString(result)
            }
            .addDisposableTo(disposeBag)
        
        
        slider.rx_value
            .subscribeNext { value in
                self.sliderValue.stringValue = "\(Int(value))"
            }
            .addDisposableTo(disposeBag)
        
        sliderValue.rx_text
            .subscribeNext { value in
                let doubleValue = value.toDouble() ?? 0.0
                self.slider.doubleValue = doubleValue
                self.sliderValue.stringValue = "\(Int(doubleValue))"
            }
            .addDisposableTo(disposeBag)
        
        disposeButton.rx_tap
            .subscribeNext { [unowned self] _ in
                print("Unbound everything")
                self.disposeBag = DisposeBag()
            }
            .addDisposableTo(disposeBag)
    }
}