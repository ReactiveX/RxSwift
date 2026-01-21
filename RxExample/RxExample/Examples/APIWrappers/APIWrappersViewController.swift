//
//  APIWrappersViewController.swift
//  RxExample
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import CoreLocation
import RxCocoa
import RxSwift
import UIKit

extension UILabel {
    override open var accessibilityValue: String! {
        get {
            text
        }
        set {
            text = newValue
            self.accessibilityValue = newValue
        }
    }
}

class APIWrappersViewController: ViewController {
    @IBOutlet var debugLabel: UILabel!

    @IBOutlet var openActionSheet: UIButton!

    @IBOutlet var openAlertView: UIButton!

    @IBOutlet var bbitem: UIBarButtonItem!

    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBOutlet var switcher: UISwitch!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var button: UIButton!

    @IBOutlet var slider: UISlider!

    @IBOutlet var textField: UITextField!
    @IBOutlet var textField2: UITextField!

    @IBOutlet var datePicker: UIDatePicker!

    @IBOutlet var mypan: UIPanGestureRecognizer!

    @IBOutlet var textView: UITextView!
    @IBOutlet var textView2: UITextView!

    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.date = Date(timeIntervalSince1970: 0)

        // MARK: UIBarButtonItem

        bbitem.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.debug("UIBarButtonItem Tapped")
            })
            .disposed(by: disposeBag)

        // MARK: UISegmentedControl

        // also test two way binding
        let segmentedValue = BehaviorRelay(value: 0)
        _ = segmentedControl.rx.value <-> segmentedValue

        segmentedValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UISegmentedControl value \(x)")
            })
            .disposed(by: disposeBag)

        // MARK: UISwitch

        // also test two way binding
        let switchValue = BehaviorRelay(value: true)
        _ = switcher.rx.value <-> switchValue

        switchValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UISwitch value \(x)")
            })
            .disposed(by: disposeBag)

        // MARK: UIActivityIndicatorView

        switcher.rx.value
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        // MARK: UIButton

        button.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.debug("UIButton Tapped")
            })
            .disposed(by: disposeBag)

        // MARK: UISlider

        // also test two way binding
        let sliderValue = BehaviorRelay<Float>(value: 1.0)
        _ = slider.rx.value <-> sliderValue

        sliderValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UISlider value \(x)")
            })
            .disposed(by: disposeBag)

        // MARK: UIDatePicker

        // also test two way binding
        let dateValue = BehaviorRelay(value: Date(timeIntervalSince1970: 0))
        _ = datePicker.rx.date <-> dateValue

        dateValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIDatePicker date \(x)")
            })
            .disposed(by: disposeBag)

        // MARK: UITextField

        // because of leak in ios 11.2
        //
        // final class UITextFieldSubclass: UITextField { deinit { print("never called")  } }
        // let textField = UITextFieldSubclass(frame: .zero)
        if #available(iOS 11.2, *) {
            // also test two way binding
            let textValue = BehaviorRelay(value: "")
            _ = textField.rx.textInput <-> textValue

            textValue.asObservable()
                .subscribe(onNext: { [weak self] x in
                    self?.debug("UITextField text \(x)")
                })
                .disposed(by: disposeBag)

            let attributedTextValue = BehaviorRelay<NSAttributedString?>(value: NSAttributedString(string: ""))
            _ = textField2.rx.attributedText <-> attributedTextValue

            attributedTextValue.asObservable()
                .subscribe(onNext: { [weak self] x in
                    self?.debug("UITextField attributedText \(x?.description ?? "")")
                })
                .disposed(by: disposeBag)
        }

        // MARK: UIGestureRecognizer

        mypan.rx.event
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIGestureRecognizer event \(x.state.rawValue)")
            })
            .disposed(by: disposeBag)

        // MARK: UITextView

        // also test two way binding
        let textViewValue = BehaviorRelay(value: "")
        _ = textView.rx.textInput <-> textViewValue

        textViewValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UITextView text \(x)")
            })
            .disposed(by: disposeBag)

        let attributedTextViewValue = BehaviorRelay<NSAttributedString?>(value: NSAttributedString(string: ""))
        _ = textView2.rx.attributedText <-> attributedTextViewValue

        attributedTextViewValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UITextView attributedText \(x?.description ?? "")")
            })
            .disposed(by: disposeBag)

        // MARK: CLLocationManager

        manager.requestWhenInUseAuthorization()

        manager.rx.didUpdateLocations
            .subscribe(onNext: { x in
                print("rx.didUpdateLocations \(x)")
            })
            .disposed(by: disposeBag)

        _ = manager.rx.didFailWithError
            .subscribe(onNext: { x in
                print("rx.didFailWithError \(x)")
            })

        manager.rx.didChangeAuthorizationStatus
            .subscribe(onNext: { status in
                print("Authorization status \(status)")
            })
            .disposed(by: disposeBag)

        manager.startUpdatingLocation()
    }

    func debug(_ string: String) {
        print(string)
        debugLabel.text = string
    }
}
