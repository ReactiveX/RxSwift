//
//  CLLocationManager+Rx.swift
//  RxExample
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import CoreLocation
import RxCocoa
import RxSwift

public extension Reactive where Base: CLLocationManager {
    /**
     Reactive wrapper for `delegate`.

     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        RxCLLocationManagerDelegateProxy.proxy(for: base)
    }

    // MARK: Responding to Location Events

    /**
     Reactive wrapper for `delegate` message.
     */
    var didUpdateLocations: Observable<[CLLocation]> {
        RxCLLocationManagerDelegateProxy.proxy(for: base).didUpdateLocationsSubject.asObservable()
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    var didFailWithError: Observable<Error> {
        RxCLLocationManagerDelegateProxy.proxy(for: base).didFailWithErrorSubject.asObservable()
    }

    #if os(iOS) || os(macOS)
    /**
     Reactive wrapper for `delegate` message.
     */
    var didFinishDeferredUpdatesWithError: Observable<Error?> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFinishDeferredUpdatesWithError:)))
            .map { a in
                try castOptionalOrThrow(Error.self, a[1])
            }
    }
    #endif

    #if os(iOS)

    // MARK: Pausing Location Updates

    /**
     Reactive wrapper for `delegate` message.
     */
    var didPauseLocationUpdates: Observable<Void> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidPauseLocationUpdates(_:)))
            .map { _ in
                ()
            }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    var didResumeLocationUpdates: Observable<Void> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidResumeLocationUpdates(_:)))
            .map { _ in
                ()
            }
    }

    // MARK: Responding to Heading Events

    /**
     Reactive wrapper for `delegate` message.
     */
    var didUpdateHeading: Observable<CLHeading> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateHeading:)))
            .map { a in
                try castOrThrow(CLHeading.self, a[1])
            }
    }

    // MARK: Responding to Region Events

    /**
     Reactive wrapper for `delegate` message.
     */
    var didEnterRegion: Observable<CLRegion> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didEnterRegion:)))
            .map { a in
                try castOrThrow(CLRegion.self, a[1])
            }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    var didExitRegion: Observable<CLRegion> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didExitRegion:)))
            .map { a in
                try castOrThrow(CLRegion.self, a[1])
            }
    }

    #endif

    #if os(iOS) || os(macOS)

    /**
     Reactive wrapper for `delegate` message.
     */
    @available(macOS 10.10, *)
    var didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion)> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didDetermineState:for:)))
            .map { a in
                let stateNumber = try castOrThrow(NSNumber.self, a[1])
                let state = CLRegionState(rawValue: stateNumber.intValue) ?? CLRegionState.unknown
                let region = try castOrThrow(CLRegion.self, a[2])
                return (state: state, region: region)
            }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    var monitoringDidFailForRegionWithError: Observable<(region: CLRegion?, error: Error)> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:monitoringDidFailFor:withError:)))
            .map { a in
                let region = try castOptionalOrThrow(CLRegion.self, a[1])
                let error = try castOrThrow(Error.self, a[2])
                return (region: region, error: error)
            }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    var didStartMonitoringForRegion: Observable<CLRegion> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didStartMonitoringFor:)))
            .map { a in
                try castOrThrow(CLRegion.self, a[1])
            }
    }

    #endif

    #if os(iOS)

    // MARK: Responding to Ranging Events

    /**
     Reactive wrapper for `delegate` message.
     */
    var didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon], region: CLBeaconRegion)> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didRangeBeacons:in:)))
            .map { a in
                let beacons = try castOrThrow([CLBeacon].self, a[1])
                let region = try castOrThrow(CLBeaconRegion.self, a[2])
                return (beacons: beacons, region: region)
            }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    var rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion, error: Error)> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:rangingBeaconsDidFailFor:withError:)))
            .map { a in
                let region = try castOrThrow(CLBeaconRegion.self, a[1])
                let error = try castOrThrow(Error.self, a[2])
                return (region: region, error: error)
            }
    }

    // MARK: Responding to Visit Events

    /**
     Reactive wrapper for `delegate` message.
     */
    @available(iOS 8.0, *)
    var didVisit: Observable<CLVisit> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didVisit:)))
            .map { a in
                try castOrThrow(CLVisit.self, a[1])
            }
    }

    #endif

    // MARK: Responding to Authorization Changes

    /**
     Reactive wrapper for `delegate` message.
     */
    var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
        delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
            .map { a in
                let number = try castOrThrow(NSNumber.self, a[1])
                return CLAuthorizationStatus(rawValue: Int32(number.intValue)) ?? .notDetermined
            }
    }
}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

private func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }

    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
