//
//  GeolocationViewController.swift
//  RxExample
//
//  Created by Carlos García on 19/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import UIKit
import CoreLocation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

private extension UILabel {
    var rx_driveCoordinates: AnyObserver<CLLocationCoordinate2D> {
        return UIBindingObserver(UIElement: self) { label, location in
            label.text = "Lat: \(location.latitude)\nLon: \(location.longitude)"
        }.asObserver()
    }
}

private extension UIView {
    var rx_driveAuthorization: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { view, authorized in
            if authorized {
                view.hidden = true
                view.superview?.sendSubviewToBack(view)
            }
            else {
                view.hidden = false
                view.superview?.bringSubviewToFront(view)
            }
        }.asObserver()
    }
}

class GeolocationViewController: ViewController {
    
    @IBOutlet weak private var noGeolocationView: UIView!
    @IBOutlet weak private var button: UIButton!
    @IBOutlet weak private var button2: UIButton!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let geolocationService = GeolocationService.instance

        geolocationService.autorized
            .drive(noGeolocationView.rx_driveAuthorization)
            .addDisposableTo(disposeBag)
        /*
        geolocationService.location
            .drive(label.rx_driveCoordinates)
            .addDisposableTo(disposeBag)

        button.rx_tap
            .bindNext { [weak self] in
                self?.openAppPreferences()
            }
            .addDisposableTo(disposeBag)
        
        button2.rx_tap
            .bindNext { [weak self] in
                self?.openAppPreferences()
            }
            .addDisposableTo(disposeBag)
        */
    }
    
    private func openAppPreferences() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }

}
