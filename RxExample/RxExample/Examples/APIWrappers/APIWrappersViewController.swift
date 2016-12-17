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

    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var mypan: UIPanGestureRecognizer!

    @IBOutlet weak var textView: UITextView!

    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.date = Date(timeIntervalSince1970: 0)

        // MARK: UIBarButtonItem

        bbitem.rx.tap
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIBarButtonItem Tapped")
            })
            .addDisposableTo(disposeBag)

        // MARK: UISegmentedControl

        // also test two way binding
        let segmentedValue = Variable(0)
        _ = segmentedControl.rx.value <-> segmentedValue

        segmentedValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UISegmentedControl value \(x)")
            })
            .addDisposableTo(disposeBag)


        // MARK: UISwitch

        // also test two way binding
        let switchValue = Variable(true)
        _ = switcher.rx.value <-> switchValue

        switchValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UISwitch value \(x)")
            })
            .addDisposableTo(disposeBag)

        // MARK: UIActivityIndicatorView

        switcher.rx.value
            .bindTo(activityIndicator.rx.isAnimating)
            .addDisposableTo(disposeBag)

        // MARK: UIButton

        button.rx.tap
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIButton Tapped")
            })
            .addDisposableTo(disposeBag)


        // MARK: UISlider

        // also test two way binding
        let sliderValue = Variable<Float>(1.0)
        _ = slider.rx.value <-> sliderValue

        sliderValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UISlider value \(x)")
            })
            .addDisposableTo(disposeBag)


        // MARK: UIDatePicker

        // also test two way binding
        let dateValue = Variable(Date(timeIntervalSince1970: 0))
        _ = datePicker.rx.date <-> dateValue


        dateValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIDatePicker date \(x)")
            })
            .addDisposableTo(disposeBag)


        // MARK: UITextField

        // also test two way binding
        let textValue = Variable("")
        _ = textField.rx.textInput <-> textValue

        textValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UITextField text \(x)")
            })
            .addDisposableTo(disposeBag)


        // MARK: UIGestureRecognizer

        mypan.rx.event
            .subscribe(onNext: { [weak self] x in
                self?.debug("UIGestureRecognizer event \(x.state)")
            })
            .addDisposableTo(disposeBag)


        // MARK: UITextView

        // also test two way binding
        let textViewValue = Variable("")
        _ = textView.rx.textInput <-> textViewValue

        textViewValue.asObservable()
            .subscribe(onNext: { [weak self] x in
                self?.debug("UITextView text \(x)")
            })
            .addDisposableTo(disposeBag)

        // MARK: CLLocationManager

        #if !RX_NO_MODULE
        manager.requestWhenInUseAuthorization()
        #endif

        manager.rx.didUpdateLocations
            .subscribe(onNext: { x in
                print("rx.didUpdateLocations \(x)")
            })
            .addDisposableTo(disposeBag)

        _ = manager.rx.didFailWithError
            .subscribe(onNext: { x in
                print("rx.didFailWithError \(x)")
            })
        
        manager.rx.didChangeAuthorizationStatus
            .subscribe(onNext: { status in
                print("Authorization status \(status)")
            })
            .addDisposableTo(disposeBag)
        
        manager.startUpdatingLocation()



    }

    func debug(_ string: String) {
        print(string)
        debugLabel.text = string
    }
}
