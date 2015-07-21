//
//  APIWrappersViewController.swift
//  RxExample
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class APIWrappersViewController: ViewController {
    
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
        
        let ash = UIActionSheet(title: "Title", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: "OK")
        let av = UIAlertView(title: "Title", message: "The message", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "OK", "Two", "Three", "Four", "Five")
        
        // MARK: UIActionSheet
        
        ash.rx_clickedButtonAtIndex
            >- subscribeNext { x in 
                print("UIActionSheet clickedButtonAtIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        ash.rx_willDismissWithButtonIndex
            >- subscribeNext { x in 
                print("UIActionSheet willDismissWithButtonIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        ash.rx_didDismissWithButtonIndex
            >- subscribeNext { x in 
                print("UIActionSheet didDismissWithButtonIndex \(x)")
                
                av.show()
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UIAlertView
        
        av.rx_clickedButtonAtIndex
            >- subscribeNext { x in 
                print("UIAlertView clickedButtonAtIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        av.rx_willDismissWithButtonIndex
            >- subscribeNext { x in 
                print("UIAlertView willDismissWithButtonIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        av.rx_didDismissWithButtonIndex
            >- subscribeNext { x in 
                print("UIAlertView didDismissWithButtonIndex \(x)")
            }
            >- disposeBag.addDisposable
        
        
        
        
        ash.showInView(view)
        
        
        // MARK: UIBarButtonItem
        
        bbitem.rx_tap
            >- subscribeNext { x in 
                print("UIBarButtonItem Tapped")
            }
            >- disposeBag.addDisposable
        
        // MARK: UISegmentedControl
        
        segmentedControl.rx_value
            >- subscribeNext { x in 
                print("UISegmentedControl value \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UISwitch
        
        switcher.rx_value
            >- subscribeNext { x in 
                print("UISwitch value \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UIButton
        
        button.rx_tap
            >- subscribeNext { x in 
                print("UIButton Tapped")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UISlider
        
        slider.rx_value
            >- subscribeNext { x in 
                print("UISlider value \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UIDatePicker
        
        datePicker.rx_date
            >- subscribeNext { x in 
                print("UIDatePicker date \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UITextField
        
        textField.rx_text
            >- subscribeNext { [unowned self] x in
                print("UITextField text \(x)")
                self.textField.resignFirstResponder()
            }
            >- disposeBag.addDisposable
        
        
        // MARK: UIGestureRecognizer
        
        mypan.rx_event
            >- subscribeNext { x in 
                print("UIGestureRecognizer event \(x)")
            }
            >- disposeBag.addDisposable
        
        
        // MARK: CLLocationManager
        
        
        manager.requestWhenInUseAuthorization()
        
        manager.rx_didUpdateLocations
            >- subscribeNext { x in 
                print("rx_didUpdateLocations \(x)")
            }
            >- disposeBag.addDisposable
        
        manager.rx_didFailWithError
            >- subscribeNext { x in 
                print("rx_didFailWithError \(x)")
            }
            >- disposeBag.addDisposable
            
        
        manager.startUpdatingLocation()
        
    }


}

