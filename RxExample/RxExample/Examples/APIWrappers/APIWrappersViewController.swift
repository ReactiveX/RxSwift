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

        let ash = UIActionSheet(title: "Title", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: "OK")
        let av = UIAlertView(title: "Title", message: "The message", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "OK", "Two", "Three", "Four", "Five")

        openActionSheet.rx_tap
            .subscribeNext { [weak self] x in
                if let view = self?.view {
                    ash.showInView(view)
                }
            }
            .addDisposableTo(disposeBag)

        openAlertView.rx_tap
            .subscribeNext { x in
                av.show()
            }
            .addDisposableTo(disposeBag)

        // MARK: UIActionSheet

        ash.rx_clickedButtonAtIndex
            .subscribeNext { [weak self] x in
                self?.debug("UIActionSheet clickedButtonAtIndex \(x)")
            }
            .addDisposableTo(disposeBag)

        ash.rx_willDismissWithButtonIndex
            .subscribeNext { [weak self] x in
                self?.debug("UIActionSheet willDismissWithButtonIndex \(x)")
            }
            .addDisposableTo(disposeBag)

        ash.rx_didDismissWithButtonIndex
            .subscribeNext { [weak self] x in
                self?.debug("UIActionSheet didDismissWithButtonIndex \(x)")
            }
            .addDisposableTo(disposeBag)


        // MARK: UIAlertView

        av.rx_clickedButtonAtIndex
            .subscribeNext { [weak self] x in
                self?.debug("UIAlertView clickedButtonAtIndex \(x)")
            }
            .addDisposableTo(disposeBag)

        av.rx_willDismissWithButtonIndex
            .subscribeNext { [weak self] x in
                self?.debug("UIAlertView willDismissWithButtonIndex \(x)")
            }
            .addDisposableTo(disposeBag)

        av.rx_didDismissWithButtonIndex
            .subscribeNext { [weak self] x in
                self?.debug("UIAlertView didDismissWithButtonIndex \(x)")
            }
            .addDisposableTo(disposeBag)







        // MARK: UIBarButtonItem

        bbitem.rx_tap
            .subscribeNext { [weak self] x in
                self?.debug("UIBarButtonItem Tapped")
            }
            .addDisposableTo(disposeBag)

        // MARK: UISegmentedControl

        segmentedControl.rx_value
            .subscribeNext { [weak self] x in
                self?.debug("UISegmentedControl value \(x)")
            }
            .addDisposableTo(disposeBag)


        // MARK: UISwitch

        switcher.rx_value
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

        slider.rx_value
            .subscribeNext { [weak self] x in
                self?.debug("UISlider value \(x)")
            }
            .addDisposableTo(disposeBag)


        // MARK: UIDatePicker

        datePicker.rx_date
            .subscribeNext { [weak self] x in
                self?.debug("UIDatePicker date \(x)")
            }
            .addDisposableTo(disposeBag)


        // MARK: UITextField

        textField.rx_text
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

        textView.rx_text
            .subscribeNext { [weak self] x in
                self?.debug("UITextView event \(x)")
            }
            .addDisposableTo(disposeBag)

        // MARK: CLLocationManager

        #if !RX_NO_MODULE
        manager.requestWhenInUseAuthorization()
        #endif

        manager.rx_didUpdateLocations
            .subscribeNext { [weak self] x in
                self?.debug("rx_didUpdateLocations \(x)")
            }
            .addDisposableTo(disposeBag)

        _ = manager.rx_didFailWithError
            .subscribeNext { [weak self] x in
                self?.debug("rx_didFailWithError \(x)")
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
