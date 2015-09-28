//
//  CLLocationManager+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
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
        return proxyForObject(self) as RxCLLocationManagerDelegateProxy
    }

    // MARK: Responding to Location Events

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didUpdateLocations: Observable<[CLLocation]!> {
        return rx_delegate.observe("locationManager:didUpdateLocations:")
            .map { a in
                return a[1] as? [CLLocation]
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didFailWithError: Observable<NSError!> {
        return rx_delegate.observe("locationManager:didFailWithError:")
            .map { a in
                return a[1] as? NSError
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didFinishDeferredUpdatesWithError: Observable<NSError!> {
        return rx_delegate.observe("locationManager:didFinishDeferredUpdatesWithError:")
            .map { a in
                return a[1] as? NSError
            }
    }

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
    #if os(iOS) || os(OSX)
    public var rx_didUpdateHeading: Observable<CLHeading!> {
        return rx_delegate.observe("locationManager:didUpdateHeading:")
            .map { a in
                return a[1] as? CLHeading
            }
    }
    #endif

    // MARK: Responding to Region Events

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didEnterRegion: Observable<CLRegion!> {
        return rx_delegate.observe("locationManager:didEnterRegion:")
            .map { a in
                return a[1] as? CLRegion
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didExitRegion: Observable<CLRegion!> {
        return rx_delegate.observe("locationManager:didExitRegion:")
            .map { a in
                return a[1] as? CLRegion
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    #if os(iOS) || os(OSX)
    @available(OSX 10.10, *)
    public var rx_didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion!)> {
        return rx_delegate.observe("locationManager:didDetermineState:forRegion:")
            .map { a in
                let stateNumber = a[1] as! NSNumber
                return (state: CLRegionState(rawValue: stateNumber.integerValue) ?? CLRegionState.Unknown, region: a[2] as? CLRegion)
            }
    }
    #endif

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_monitoringDidFailForRegionWithError: Observable<(region: CLRegion!, error: NSError!)> {
        return rx_delegate.observe("locationManager:monitoringDidFailForRegion:withError:")
            .map { a in
                return (region: a[1] as? CLRegion, error: a[2] as? NSError)
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didStartMonitoringForRegion: Observable<CLRegion!> {
        return rx_delegate.observe("locationManager:didStartMonitoringForRegion:")
            .map { a in
                return a[1] as? CLRegion
            }
    }

    // MARK: Responding to Ranging Events

#if os(iOS)

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon]!, region: CLBeaconRegion!)> {
        return rx_delegate.observe("locationManager:didRangeBeacons:inRegion:")
            .map { a in
                return (beacons: a[1] as? [CLBeacon], region: a[2] as? CLBeaconRegion)
            }
    }

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion!, error: NSError!)> {
        return rx_delegate.observe("locationManager:rangingBeaconsDidFailForRegion:withError:")
            .map { a in
                return (region: a[1] as? CLBeaconRegion, error: a[2] as? NSError)
            }
    }

    // MARK: Responding to Visit Events

    /**
    Reactive wrapper for `delegate` message.
    */
    @available(iOS 8.0, *)
    public var rx_didVisit: Observable<CLVisit!> {
        return rx_delegate.observe("locationManager:didVisit:")
            .map { a in
                return a[1] as? CLVisit
            }
    }

#endif

    // MARK: Responding to Authorization Changes

    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didChangeAuthorizationStatus: Observable<CLAuthorizationStatus?> {
        return rx_delegate.observe("locationManager:didChangeAuthorizationStatus:")
            .map { a in
                let number = a[1] as! NSNumber
                return CLAuthorizationStatus(rawValue: Int32(number.integerValue))
            }
    }



}
