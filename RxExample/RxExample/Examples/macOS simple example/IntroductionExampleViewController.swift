//
//  IntroductionExampleViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 5/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import Cocoa
import AppKit

class IntroductionExampleViewController : ViewController {
    @IBOutlet var a: NSTextField!
    @IBOutlet var b: NSTextField!
    @IBOutlet var c: NSTextField!

    @IBOutlet var leftTextView: NSTextView!
    @IBOutlet var rightTextView: NSTextView!
    
    @IBOutlet var speechEnabled: NSButton!
    @IBOutlet var slider: NSSlider!
    @IBOutlet var sliderValue: NSTextField!
    
    @IBOutlet var disposeButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // c = a + b
        let sum = Observable.combineLatest(a.rx.text.orEmpty, b.rx.text.orEmpty) { (a: String, b: String) -> (a: Int, b: Int) in
            return (Int(a) ?? 0, Int(b) ?? 0)
        }
        
        // bind result to UI
        sum
            .map { pair in
                return "\(pair.a + pair.b)"
            }
            .bind(to: c.rx.text)
            .disposed(by: disposeBag)
        
        // Also, tell it out loud
        let speech = NSSpeechSynthesizer()
        
        Observable.combineLatest(sum, speechEnabled.rx.state) { (operands: $0, state: $1) }
            .flatMapLatest { pair -> Observable<String> in
                let (a, b) = pair.operands
                if pair.state == NSControl.StateValue.off {
                    return .empty()
                }

                return .just("\(a) + \(b) = \(a + b)")
            }
            .subscribe(onNext: { result in
                if speech.isSpeaking {
                    speech.stopSpeaking()
                }
                
                speech.startSpeaking(result)
            })
            .disposed(by: disposeBag)
        
        
        slider.rx.value
            .subscribe(onNext: { value in
                self.sliderValue.stringValue = "\(Int(value))"
            })
            .disposed(by: disposeBag)
        
        sliderValue.rx.text.orEmpty
            .subscribe(onNext: { value in
                let doubleValue = value.toDouble() ?? 0.0
                self.slider.doubleValue = doubleValue
                self.sliderValue.stringValue = "\(Int(doubleValue))"
            })
            .disposed(by: disposeBag)
        
        disposeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                print("Unbind everything")
                self?.disposeBag = DisposeBag()
            })
            .disposed(by: disposeBag)
    }
}
