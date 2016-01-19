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

class GeolocationViewController: UIViewController {
    
    @IBOutlet weak var noGeolocationView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    
    private let geolocationService = GeolocationService.instance
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        geolocationService.status
            .driveNext(manageGeolocationStatus)
            .addDisposableTo(disposeBag)
        
        geolocationService.locationChange
            .driveNext(showCoordinates)
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
    
    private func showCoordinates(location: CLLocationCoordinate2D) {
        latLabel.text = "Latitude: \(location.latitude)"
        lonLabel.text = "Longitude: \(location.longitude)"
    }
    
    private func manageGeolocationStatus(status: GeolocationStatus) {
        switch status {
        case .Disabled:
            noGeolocationView.hidden = false
            view.bringSubviewToFront(noGeolocationView)
            
        case .Enabled:
            noGeolocationView.hidden = true
            view.sendSubviewToBack(noGeolocationView)
        }
    }

}
