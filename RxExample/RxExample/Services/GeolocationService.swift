//
//  GeolocationService.swift
//  RxExample
//
//  Created by Carlos García on 19/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import CoreLocation
import RxCocoa
import RxSwift

class GeolocationService {
    static let instance = GeolocationService()
    private(set) var authorized: Driver<Bool>
    private(set) var location: Driver<CLLocationCoordinate2D>

    private let locationManager = CLLocationManager()

    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        authorized = Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager else {
                return Observable.just(status)
            }
            return locationManager
                .rx.didChangeAuthorizationStatus
                .startWith(status)
        }
        .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
        .map {
            switch $0 {
            case .authorizedAlways:
                true
            case .authorizedWhenInUse:
                true
            default:
                false
            }
        }

        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map(\.coordinate)

        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
}
