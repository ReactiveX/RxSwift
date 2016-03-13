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
    public override var accessibilityValue: String! {
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

        datePicker.date = NSDate(timeIntervalSince1970: 0)

        // MARK: UIBarButtonItem

        bbitem.rx_tap
            .subscribeNext { [weak self] x in
                self?.debug("UIBarButtonItem Tapped")
            }
            .addDisposableTo(disposeBag)

        // MARK: UISegmentedControl

        // also test two way binding
        let segmentedValue = Variable(0)
        segmentedControl.rx_value <-> segmentedValue

        segmentedValue.asObservable()
            .subscribeNext { [weak self] x in
                self?.debug("UISegmentedControl value \(x)")
            }
            .addDisposableTo(disposeBag)


        // MARK: UISwitch

        // also test two way binding
        let switchValue = Variable(true)
        switcher.rx_value <-> switchValue

        switchValue.asObservable()
            .subscribeNext { [weak self] x in
                self?.debug("UISwitch value \(x)")
            }
            .addDisposableTo(disposeBag)

        // MARK: UIActivityIndicatorView

        switcher.rx_value
            .bindTo(activityIndicator.rx_animating)
            .addDisposableTo(disposeBag)


        // MARK: UIButton

        button.rx_tap
            .subscribeNext { [weak self] x in
                self?.debug("UIButton Tapped")
            }
            .addDisposableTo(disposeBag)


        // MARK: UISlider

        // also test two way binding
        let sliderValue = Variable<Float>(1.0)
        slider.rx_value <-> sliderValue

        sliderValue.asObservable()
            .subscribeNext { [weak self] x in
                self?.debug("UISlider value \(x)")
            }
            .addDisposableTo(disposeBag)


        // MARK: UIDatePicker

        // also test two way binding
        let dateValue = Variable(NSDate(timeIntervalSince1970: 0))
        datePicker.rx_date <-> dateValue


        dateValue.asObservable()
            .subscribeNext { [weak self] x in
                self?.debug("UIDatePicker date \(x)")
            }
            .addDisposableTo(disposeBag)


        // MARK: UITextField

        // also test two way binding
        let textValue = Variable("")
        textField.rx_text <-> textValue

        textValue.asObservable()
            .subscribeNext { [weak self] x in
                self?.debug("UITextField text \(x)")
            }
            .addDisposableTo(disposeBag)


        // MARK: UIGestureRecognizer

        mypan.rx_event
            .subscribeNext { [weak self] x in
                self?.debug("UIGestureRecognizer event \(x.state)")
            }
            .addDisposableTo(disposeBag)


        // MARK: UITextView

        // also test two way binding
        let textViewValue = Variable("")
        textView.rx_text <-> textViewValue

        textViewValue.asObservable()
            .subscribeNext { [weak self] x in
                self?.debug("UITextView text \(x)")
            }
            .addDisposableTo(disposeBag)

        // MARK: CLLocationManager

        #if !RX_NO_MODULE
        manager.requestWhenInUseAuthorization()
        #endif

        manager.rx_didUpdateLocations
            .subscribeNext { x in
                print("rx_didUpdateLocations \(x)")
            }
            .addDisposableTo(disposeBag)

        _ = manager.rx_didFailWithError
            .subscribeNext { x in
                print("rx_didFailWithError \(x)")
            }
        
        manager.rx_didChangeAuthorizationStatus
            .subscribeNext { status in
                print("Authorization status \(status)")
            }
            .addDisposableTo(disposeBag)
        
        manager.startUpdatingLocation()



    }

    func debug(string: String) {
        print(string)
        debugLabel.text = string
    }
}
