//
//  RxCLLocationManagerDelegateProxy.swift
//  RxExample
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import CoreLocation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class RxCLLocationManagerDelegateProxy<P: CLLocationManager>
    : DelegateProxy<P, CLLocationManagerDelegate>
    , DelegateProxyType
    , CLLocationManagerDelegate {

    static var factory: DelegateProxyFactory {
        return DelegateProxyFactory.sharedFactory(for: RxCLLocationManagerDelegateProxy<CLLocationManager>.self)
    }

    internal lazy var didUpdateLocationsSubject = PublishSubject<[CLLocation]>()
    internal lazy var didFailWithErrorSubject = PublishSubject<Error>()

    override class func currentDelegate(for object: ParentObject) -> CLLocationManagerDelegate? {
        return object.delegate
    }

    override class func setCurrentDelegate(_ delegate: CLLocationManagerDelegate?, toObject object: ParentObject) {
        object.delegate = delegate
    }

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
