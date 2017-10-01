//
//  APIWrappersViewController.swift
//  RxExample
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import CoreLocation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

extension UILabel {
    open override var accessibilityValue: String! {
        get {
            return self.text
        }
        set {
            self.text = newValue
            self.accessibilityValue = newValue
        }
    }
}

class APIWrappersViewController: ViewController {

    @IBOutlet weak var debugLabel: UILabel!

    @IBOutlet weak var openActionSheet: UIButton!

    @IBOutlet weak var openAlertView: UIButton!

    @IBOutlet weak var bbitem: UIBarButtonItem!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var switcher: UISwitch!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var button: UIButton!

    @IBOutlet weak var slider: UISlider!

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textField2: UITextField!

    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var mypan: UIPanGestureRecognizer!

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textView2: UITextView!

    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.date = Date(timeIntervalSince1970: 0)

        // MARK: UIBarButtonItem

        bbitem.rx.tap
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIBarButtonItem Tapped")
            })
            .disposed(by: disposeBag)

        // MARK: UISegmentedControl

        // also test two way binding
        let segmentedValue = Variable(0)
        _ = segmentedControl.rx.value <-> segmentedValue

        segmentedValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UISegmentedControl value \(x)")
            })
            .disposed(by: disposeBag)


        // MARK: UISwitch

        // also test two way binding
        let switchValue = Variable(true)
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
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIButton Tapped")
            })
            .disposed(by: disposeBag)


        // MARK: UISlider

        // also test two way binding
        let sliderValue = Variable<Float>(1.0)
        _ = slider.rx.value <-> sliderValue

        sliderValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UISlider value \(x)")
            })
            .disposed(by: disposeBag)


        // MARK: UIDatePicker

        // also test two way binding
        let dateValue = Variable(Date(timeIntervalSince1970: 0))
        _ = datePicker.rx.date <-> dateValue


        dateValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIDatePicker date \(x)")
            })
            .disposed(by: disposeBag)


        // MARK: UITextField

        // also test two way binding
        let textValue = Variable("")
        _ = textField.rx.textInput <-> textValue

        textValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UITextField text \(x)")
            })
            .disposed(by: disposeBag)

        textValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UITextField text \(x)")
            })
            .disposed(by: disposeBag)

        let attributedTextValue = Variable<NSAttributedString?>(NSAttributedString(string: ""))
        _ = textField2.rx.attributedText <-> attributedTextValue

        attributedTextValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UITextField attributedText \(x?.description ?? "")")
            })
            .disposed(by: disposeBag)

        // MARK: UIGestureRecognizer

        mypan.rx.event
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIGestureRecognizer event \(x.state.rawValue)")
            })
            .disposed(by: disposeBag)


        // MARK: UITextView

        // also test two way binding
        let textViewValue = Variable("")
        _ = textView.rx.textInput <-> textViewValue

        textViewValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UITextView text \(x)")
            })
            .disposed(by: disposeBag)

        let attributedTextViewValue = Variable<NSAttributedString?>(NSAttributedString(string: ""))
        _ = textView2.rx.attributedText <-> attributedTextViewValue

        attributedTextViewValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UITextView attributedText \(x?.description ?? "")")
            })
            .disposed(by: disposeBag)

        // MARK: CLLocationManager

        #if !RX_NO_MODULE
        manager.requestWhenInUseAuthorization()
        #endif

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
