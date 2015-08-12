//
//  APIWrappersViewController.swift
//  RxExample
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
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
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var mypan: UIPanGestureRecognizer!
    
    let disposeBag = DisposeBag()
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = NSDate(timeIntervalSince1970: 0)
        
        let ash = UIActionSheet(title: "Title", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: "OK")
        let av = UIAlertView(title: "Title", message: "The message", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "OK", "Two", "Three", "Four", "Five")
        
        openActionSheet.rx_tap
            >- subscribeNext { x in 
                ash.showInView(self.view)
            }
            >- disposeBag.addDisposable
        
        openAlertView.rx_tap
            >- subscribeNext { x in 
                av.show()
            }
            >- disposeBag.addDisposable
        
        // MARK: UIActionSheet
        
        ash.rx_clickedButtonAtIndex
            >- subscribeNext { [weak self] x in 
                self?.debug("UIActionSheet clickedButtonAtIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        ash.rx_willDismissWithButtonIndex
            >- subscribeNext { [weak self] x in 
                self?.debug("UIActionSheet willDismissWithButtonIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        ash.rx_didDismissWithButtonIndex
            >- subscribeNext { [weak self] x in 
                self?.debug("UIActionSheet didDismissWithButtonIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UIAlertView
        
        av.rx_clickedButtonAtIndex
            >- subscribeNext { [weak self] x in 
                self?.debug("UIAlertView clickedButtonAtIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        av.rx_willDismissWithButtonIndex
            >- subscribeNext { [weak self] x in 
                self?.debug("UIAlertView willDismissWithButtonIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        av.rx_didDismissWithButtonIndex
            >- subscribeNext { [weak self] x in 
                self?.debug("UIAlertView didDismissWithButtonIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        
        
        
        
        
        
        // MARK: UIBarButtonItem
        
        bbitem.rx_tap
            >- subscribeNext { [weak self] x in 
                self?.debug("UIBarButtonItem Tapped")
            }
            >- disposeBag.addDisposable
        
        // MARK: UISegmentedControl
        
        segmentedControl.rx_value
            >- subscribeNext { [weak self] x in 
                self?.debug("UISegmentedControl value \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UISwitch
        
        switcher.rx_value
            >- subscribeNext { [weak self] x in 
                self?.debug("UISwitch value \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UIButton
        
        button.rx_tap
            >- subscribeNext { [weak self] x in 
                self?.debug("UIButton Tapped")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UISlider
        
        slider.rx_value
            >- subscribeNext { [weak self] x in 
                self?.debug("UISlider value \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UIDatePicker
        
        datePicker.rx_date
            >- subscribeNext { [weak self] x in 
                self?.debug("UIDatePicker date \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UITextField
        
        textField.rx_text
            >- subscribeNext { [weak self] x in 
                self?.debug("UITextField text \(x)")
                self?.textField.resignFirstResponder()
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UIGestureRecognizer
        
        mypan.rx_event
            >- subscribeNext { [weak self] x in 
                self?.debug("UIGestureRecognizer event \(x.state)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: CLLocationManager
        
        
        if manager.respondsToSelector("requestWhenInUseAuthorization") {
            manager.requestWhenInUseAuthorization()
        }
        
        manager.rx_didUpdateLocations
            >- subscribeNext { [weak self] x in 
                self?.debug("rx_didUpdateLocations \(x)")
            }
            >- disposeBag.addDisposable
        
        manager.rx_didFailWithError
            >- subscribeNext { [weak self] x in 
                self?.debug("rx_didFailWithError \(x)")
            }
            >- disposeBag.addDisposable
        
        
        manager.rx_didChangeAuthorizationStatus
            >- subscribeNext { status in
                println("Authorization status \(status)")
            }
            >- disposeBag.addDisposable
        
        manager.startUpdatingLocation()
        
        
        
    }
    
    func debug(string: String) {
        println(string)
        debugLabel.text = string
    }
}

