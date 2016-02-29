//
//  CLLocationManager+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import CoreLocation
#if !RX_NO_MODULE
import RxSwift
#endif


extension CLLocationManager {

    /**
    Reactive wrapper for `delegate`.

    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxCLLocationManagerDelegateProxy.self, self)
    }

    // MARK: Responding to Location Events

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didUpdateLocations: Observable<[CLLocation]> {
        return rx_delegate.observe("locationManager:didUpdateLocations:")
            .map { a in
                return try castOrThrow([CLLocation].self, a[1])
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didFailWithError: Observable<NSError> {
        return rx_delegate.observe("locationManager:didFailWithError:")
            .map { a in
                return try castOrThrow(NSError.self, a[1])
            }
    }

    #if os(iOS) || os(watchOS) || os(OSX)
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didFinishDeferredUpdatesWithError: Observable<NSError?> {
        return rx_delegate.observe("locationManager:didFinishDeferredUpdatesWithError:")
            .map { a in
                return try castOptionalOrThrow(NSError.self, a[1])
            }
    }
    #endif

    #if os(iOS)

    // MARK: Pausing Location Updates

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didPauseLocationUpdates: Observable<Void> {
        return rx_delegate.observe("locationManagerDidPauseLocationUpdates:")
            .map { _ in
                return ()
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didResumeLocationUpdates: Observable<Void> {
        return rx_delegate.observe("locationManagerDidResumeLocationUpdates:")
            .map { _ in
                return ()
            }
    }

    // MARK: Responding to Heading Events

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didUpdateHeading: Observable<CLHeading> {
        return rx_delegate.observe("locationManager:didUpdateHeading:")
            .map { a in
                return try castOrThrow(CLHeading.self, a[1])
            }
    }

    // MARK: Responding to Region Events

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didEnterRegion: Observable<CLRegion> {
        return rx_delegate.observe("locationManager:didEnterRegion:")
            .map { a in
                return try castOrThrow(CLRegion.self, a[1])
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didExitRegion: Observable<CLRegion> {
        return rx_delegate.observe("locationManager:didExitRegion:")
            .map { a in
                return try castOrThrow(CLRegion.self, a[1])
            }
    }

    #endif

    #if os(iOS) || os(OSX)
    
    /**
    Reactive wrapper for `delegate` message.
    */
    @available(OSX 10.10, *)
    public var rx_didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion)> {
        return rx_delegate.observe("locationManager:didDetermineState:forRegion:")
            .map { a in
                let stateNumber = try castOrThrow(NSNumber.self, a[1])
                let state = CLRegionState(rawValue: stateNumber.integerValue) ?? CLRegionState.Unknown
                let region = try castOrThrow(CLRegion.self, a[2])
                return (state: state, region: region)
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_monitoringDidFailForRegionWithError: Observable<(region: CLRegion?, error: NSError)> {
        return rx_delegate.observe("locationManager:monitoringDidFailForRegion:withError:")
            .map { a in
                let region = try castOptionalOrThrow(CLRegion.self, a[1])
                let error = try castOrThrow(NSError.self, a[2])
                return (region: region, error: error)
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didStartMonitoringForRegion: Observable<CLRegion> {
        return rx_delegate.observe("locationManager:didStartMonitoringForRegion:")
            .map { a in
                return try castOrThrow(CLRegion.self, a[1])
            }
    }

    #endif

    #if os(iOS)

    // MARK: Responding to Ranging Events

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon], region: CLBeaconRegion)> {
        return rx_delegate.observe("locationManager:didRangeBeacons:inRegion:")
            .map { a in
                let beacons = try castOrThrow([CLBeacon].self, a[1])
                let region = try castOrThrow(CLBeaconRegion.self, a[2])
                return (beacons: beacons, region: region)
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion, error: NSError)> {
        return rx_delegate.observe("locationManager:rangingBeaconsDidFailForRegion:withError:")
            .map { a in
                let region = try castOrThrow(CLBeaconRegion.self, a[1])
                let error = try castOrThrow(NSError.self, a[2])
                return (region: region, error: error)
            }
    }

    // MARK: Responding to Visit Events

    /**
    Reactive wrapper for `delegate` message.
    */
    @available(iOS 8.0, *)
    public var rx_didVisit: Observable<CLVisit> {
        return rx_delegate.observe("locationManager:didVisit:")
            .map { a in
                return try castOrThrow(CLVisit.self, a[1])
            }
    }

    #endif

    // MARK: Responding to Authorization Changes

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
        return rx_delegate.observe("locationManager:didChangeAuthorizationStatus:")
            .map { a in
                let number = try castOrThrow(NSNumber.self, a[1])
                return CLAuthorizationStatus(rawValue: Int32(number.integerValue)) ?? .NotDetermined
            }
    }



}
