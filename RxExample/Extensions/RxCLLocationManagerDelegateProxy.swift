//
//  RxCLLocationManagerDelegateProxy.swift
//  RxExample
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import CoreLocation
import RxCocoa
import RxSwift

extension CLLocationManager: @retroactive HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

public class RxCLLocationManagerDelegateProxy:
    DelegateProxy<CLLocationManager, CLLocationManagerDelegate>,
    DelegateProxyType,
    CLLocationManagerDelegate
{
    public init(locationManager: CLLocationManager) {
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
    }

    lazy var didUpdateLocationsSubject = PublishSubject<[CLLocation]>()
    lazy var didFailWithErrorSubject = PublishSubject<Error>()

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _forwardToDelegate?.locationManager?(manager, didUpdateLocations: locations)
        didUpdateLocationsSubject.onNext(locations)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _forwardToDelegate?.locationManager?(manager, didFailWithError: error)
        didFailWithErrorSubject.onNext(error)
    }

    deinit {
        self.didUpdateLocationsSubject.on(.completed)
        self.didFailWithErrorSubject.on(.completed)
    }
}
