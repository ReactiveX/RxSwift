//
//  GeolocationService.swift
//  RxExample
//
//  Created by Carlos García on 19/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import CoreLocation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif



enum GeolocationError: ErrorType {
    case NoLocation
}

enum GeolocationStatus {
    case Enabled
    case Disabled
    
    static private func fromCLAuthorizationStatus(status: CLAuthorizationStatus) -> GeolocationStatus {
        switch status {
        case .AuthorizedAlways:
            return .Enabled
        default:
            return .Disabled
        }
    }
}

class GeolocationService {
    
    static let instance = GeolocationService()
    private (set) var status: Driver<GeolocationStatus>
    private (set) var locationChange: Driver<CLLocationCoordinate2D>
    
    private let locationManager = CLLocationManager()
    
    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        status = locationManager.rx_didChangeAuthorizationStatus
            .startWith(CLLocationManager.authorizationStatus())
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.NotDetermined)
            .map(GeolocationStatus.fromCLAuthorizationStatus)
        
        locationChange = locationManager.rx_didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .filter { array -> Bool in array.count > 0 }
            .map { $0.last!.coordinate }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}