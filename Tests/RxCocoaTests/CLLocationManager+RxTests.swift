//
//  CLLocationManager+RxTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 12/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import XCTest
import CoreLocation

class CLLocationManagerTests : RxTest {

}

// delegate methods

extension CLLocationManagerTests {
    func testDidUpdateLocations() {
        var completed = false
        var location: CLLocation?

        let targetLocation = CLLocation(latitude: 90, longitude: 180)

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didUpdateLocations.subscribe(onNext: { l in
                    location = l[0]
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didUpdateLocations: [targetLocation])
        }

        XCTAssertEqual(location?.coordinate.latitude, targetLocation.coordinate.latitude)
        XCTAssertEqual(location?.coordinate.longitude, targetLocation.coordinate.longitude)
        XCTAssertTrue(completed)
    }

    func testDidFailWithError() {
        var completed = false
        var error: NSError?

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didFailWithError.subscribe(onNext: { e in
                error = e
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didFailWithError: testError)
        }

        XCTAssertEqual(error, testError)
        XCTAssertTrue(completed)
    }

    #if os(iOS) || os(OSX)

    func testDidFinishDeferredUpdatesWithError() {
        var completed = false
        var error: NSError?

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didFinishDeferredUpdatesWithError.subscribe(onNext: { e in
                error = e
                }, onCompleted: {
                    completed = true
            })

            manager.delegate!.locationManager!(manager, didFinishDeferredUpdatesWithError: testError)
        }

        XCTAssertEqual(error, testError)
        XCTAssertTrue(completed)
    }

    func testDidFinishDeferredUpdatesWithError_noError() {
        var completed = false
        var error: NSError?

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didFinishDeferredUpdatesWithError.subscribe(onNext: { e in
                error = e
                }, onCompleted: {
                    completed = true
            })

            manager.delegate!.locationManager!(manager, didFinishDeferredUpdatesWithError: nil)
        }

        XCTAssertEqual(error, nil)
        XCTAssertTrue(completed)
    }

    #endif

    #if os(iOS)

    func testDidPauseLocationUpdates() {
        var completed = false
        var updates: ()?

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didPauseLocationUpdates.subscribe(onNext: { u in
                    updates = u
                }, onCompleted: {
                    completed = true
            })

            manager.delegate!.locationManagerDidPauseLocationUpdates!(manager)
        }

        XCTAssertTrue(updates != nil)
        XCTAssertTrue(completed)
    }

    func testDidResumeLocationUpdates() {
        var completed = false
        var updates: ()?

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didResumeLocationUpdates.subscribe(onNext: { _ in
                    updates = ()
                }, onCompleted: {
                    completed = true
            })

            manager.delegate!.locationManagerDidResumeLocationUpdates!(manager)
        }

        XCTAssertTrue(updates != nil)
        XCTAssertTrue(completed)
    }

    func testDidUpdateHeading() {
        var completed = false
        var heading: CLHeading?

        let targetHeading = CLHeading()

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didUpdateHeading.subscribe(onNext: { n in
                    heading = n
                }, onCompleted: {
                    completed = true
            })

            manager.delegate!.locationManager!(manager, didUpdateHeading: targetHeading)
        }

        XCTAssertEqual(heading, targetHeading)
        XCTAssertTrue(completed)
    }

    func testDidEnterRegion() {
        var completed = false
        var value: CLRegion?

        let targetValue = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 90, longitude: 180), radius: 10, identifier: "unit tests in cloud")

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didEnterRegion.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didEnterRegion: targetValue)
        }

        XCTAssertEqual(value, targetValue)
        XCTAssertTrue(completed)
    }

    func testDidExitRegion() {
        var completed = false
        var value: CLRegion?

        let targetValue = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 90, longitude: 180), radius: 10, identifier: "unit tests in cloud")

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didExitRegion.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didExitRegion: targetValue)
        }

        XCTAssertEqual(value, targetValue)
        XCTAssertTrue(completed)
    }

    #endif

    #if os(iOS) || os(OSX)

    func testDidDetermineStateForRegion() {
        var completed = false
        var value: (CLRegionState, CLRegion)?

        let targetValue = (CLRegionState.Inside, CLCircularRegion(center: CLLocationCoordinate2D(latitude: 90, longitude: 180), radius: 10, identifier: "unit tests in cloud"))

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didDetermineStateForRegion.subscribe(onNext: { n in
                    value = (n.state, n.region)
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didDetermineState: targetValue.0, forRegion: targetValue.1)
        }

        XCTAssertEqual(value?.0, targetValue.0)
        XCTAssertEqual(value?.1, targetValue.1)
        XCTAssertTrue(completed)
    }

    func testMonitorOfKnownRegionDidFailWithError() {
        var completed = false
        var region: CLRegion?
        var error: NSError?

        let targetRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 90, longitude: 180), radius: 10, identifier: "unit tests in cloud")

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_monitoringDidFailForRegionWithError.subscribe(onNext: { l in
                    region = l.region
                    error = l.error
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, monitoringDidFailForRegion: targetRegion, withError: testError)
        }

        XCTAssertEqual(targetRegion, region)
        XCTAssertEqual(error, testError)
        XCTAssertTrue(completed)
    }

    func testMonitorOfUnknownRegionDidFailWithError() {
        var completed = false
        var region: CLRegion?
        var error: NSError?

        let targetRegion: CLRegion? = nil

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_monitoringDidFailForRegionWithError.subscribe(onNext: { l in
                region = l.region
                error = l.error
                }, onCompleted: {
                    completed = true
            })

            manager.delegate!.locationManager!(manager, monitoringDidFailForRegion: targetRegion, withError: testError)
        }

        XCTAssertEqual(targetRegion, region)
        XCTAssertEqual(error, testError)
        XCTAssertTrue(completed)
    }

    func testStartMonitoringForRegion() {
        var completed = false
        var value: CLRegion?

        let targetValue = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 90, longitude: 180), radius: 10, identifier: "unit tests in cloud")

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didStartMonitoringForRegion.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didStartMonitoringForRegion: targetValue)
        }

        XCTAssertEqual(value, targetValue)
        XCTAssertTrue(completed)
    }

    #endif

    #if os(iOS)
    func testDidRangeBeaconsInRegion() {
        var completed = false
        var value: ([CLBeacon], CLBeaconRegion)?

        let targetValue = (
            [CLBeacon()],
            CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "68753A44-4D6F-1226-9C60-0050E4C00067")!, identifier: "1231231")
        )

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didRangeBeaconsInRegion.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didRangeBeacons: targetValue.0, inRegion: targetValue.1)
        }

        XCTAssertEqual(value!.0, targetValue.0)
        XCTAssertEqual(value!.1, targetValue.1)
        XCTAssertTrue(completed)
    }

    func testRangingBeaconsDidFailForRegionWithError() {
        var completed = false
        var value: (CLBeaconRegion, NSError)?

        let targetValue = (
            CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "68753A44-4D6F-1226-9C60-0050E4C00067")!, identifier: "1231231"),
            testError
        )

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_rangingBeaconsDidFailForRegionWithError.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, rangingBeaconsDidFailForRegion: targetValue.0, withError: targetValue.1)
        }

        XCTAssertEqual(value!.0, targetValue.0)
        XCTAssertEqual(value!.1, targetValue.1)
        XCTAssertTrue(completed)
    }

    func testDidVisit() {
        var completed = false
        var value: CLVisit?

        let targetValue = (
            CLVisit()
        )

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didVisit.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didVisit: targetValue)
        }

        XCTAssertEqual(value, targetValue)
        XCTAssertTrue(completed)
    }
    #endif

    func testDidChangeAuthorizationStatus() {
        var completed = false
        var authorizationStatus: CLAuthorizationStatus?

        #if os(tvOS)
        let targetAuthorizationStatus = CLAuthorizationStatus.AuthorizedAlways
        #elseif os(iOS)
        let targetAuthorizationStatus = CLAuthorizationStatus.AuthorizedAlways
        #else
        let targetAuthorizationStatus = CLAuthorizationStatus.Authorized
        #endif

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx_didChangeAuthorizationStatus.subscribe(onNext: { status in
                    authorizationStatus = status
                }, onCompleted: {
                    completed = true
            })

            manager.delegate!.locationManager!(manager, didChangeAuthorizationStatus:targetAuthorizationStatus)
        }

        XCTAssertEqual(authorizationStatus, targetAuthorizationStatus)
        XCTAssertTrue(completed)
    }
}