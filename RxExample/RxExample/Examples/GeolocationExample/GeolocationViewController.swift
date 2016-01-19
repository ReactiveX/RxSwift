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

class GeolocationViewController: ViewController {
    
    @IBOutlet weak private var noGeolocationView: UIView!
    @IBOutlet weak private var button: UIButton!
    @IBOutlet weak private var button2: UIButton!
    @IBOutlet weak private var latLabel: UILabel!
    @IBOutlet weak private var lonLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let geolocationService = GeolocationService.instance
        
        geolocationService.autorized
            .driveNext(driveAutorization)
            .addDisposableTo(disposeBag)
        
        geolocationService.location
            .driveNext(driveCoordinates)
            .addDisposableTo(disposeBag)
        
        button.rx_tap
            .bindNext(openAppPreferences)
            .addDisposableTo(disposeBag)
        
        button2.rx_tap
            .bindNext(openAppPreferences)
            .addDisposableTo(disposeBag)
        
    }
    
    private func openAppPreferences() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    private func driveCoordinates(location: CLLocationCoordinate2D) {
        latLabel.text = "Latitude: \(location.latitude)"
        lonLabel.text = "Longitude: \(location.longitude)"
    }
    
    private func driveAutorization(autorized: Bool) {
        if autorized {
            noGeolocationView.hidden = true
            view.sendSubviewToBack(noGeolocationView)
        }
        else {
            noGeolocationView.hidden = false
            view.bringSubviewToFront(noGeolocationView)
        }
    }

}
