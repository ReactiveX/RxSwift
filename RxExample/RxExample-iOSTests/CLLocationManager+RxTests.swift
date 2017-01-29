//
//  CLLocationManager+RxTests.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

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

            _ = manager.rx.didUpdateLocations.subscribe(onNext: { l in
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
            
            _ = manager.rx.didFailWithError.subscribe(onNext: { e in
                error = e
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didFailWithError: testError)
        }

        XCTAssertEqual(error, testError)
        XCTAssertTrue(completed)
    }

    #if os(iOS) || os(macOS)

    func testDidFinishDeferredUpdatesWithError() {
        var completed = false
        var error: NSError?

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx.didFinishDeferredUpdatesWithError.subscribe(onNext: { e in
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

            _ = manager.rx.didFinishDeferredUpdatesWithError.subscribe(onNext: { e in
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

            _ = manager.rx.didPauseLocationUpdates.subscribe(onNext: { u in
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

            _ = manager.rx.didResumeLocationUpdates.subscribe(onNext: { _ in
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

            _ = manager.rx.didUpdateHeading.subscribe(onNext: { n in
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

            _ = manager.rx.didEnterRegion.subscribe(onNext: { n in
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

            _ = manager.rx.didExitRegion.subscribe(onNext: { n in
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

    #if os(iOS) || os(macOS)

    func testDidDetermineStateForRegion() {
        var completed = false
        var value: (CLRegionState, CLRegion)?

        let targetValue = (CLRegionState.inside, CLCircularRegion(center: CLLocationCoordinate2D(latitude: 90, longitude: 180), radius: 10, identifier: "unit tests in cloud"))

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx.didDetermineStateForRegion.subscribe(onNext: { n in
                    value = (n.state, n.region)
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didDetermineState: targetValue.0, for: targetValue.1)
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

            _ = manager.rx.monitoringDidFailForRegionWithError.subscribe(onNext: { l in
                    region = l.region
                    error = l.error
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, monitoringDidFailFor: targetRegion, withError: testError)
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

            _ = manager.rx.monitoringDidFailForRegionWithError.subscribe(onNext: { l in
                region = l.region
                error = l.error
                }, onCompleted: {
                    completed = true
            })

            manager.delegate!.locationManager!(manager, monitoringDidFailFor: targetRegion, withError: testError)
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

            _ = manager.rx.didStartMonitoringForRegion.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didStartMonitoringFor: targetValue)
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
         // [CLBeacon()]
         // TODO: This crashes on Xcode 8.0 beta version
         // this is temporary workaround
         [] as [CLBeacon],
            CLBeaconRegion(proximityUUID: UUID(uuidString: "68753A44-4D6F-1226-9C60-0050E4C00067")!, identifier: "1231231")
        )

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx.didRangeBeaconsInRegion.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, didRangeBeacons: targetValue.0, in: targetValue.1)
        }

        XCTAssertEqual(value!.0, targetValue.0)
        XCTAssertEqual(value!.1, targetValue.1)
        XCTAssertTrue(completed)
        
    }

    func testRangingBeaconsDidFailForRegionWithError() {
        var completed = false
        var value: (CLBeaconRegion, NSError)?

        let targetValue = (
            CLBeaconRegion(proximityUUID: UUID(uuidString: "68753A44-4D6F-1226-9C60-0050E4C00067")!, identifier: "1231231"),
            testError
        )

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx.rangingBeaconsDidFailForRegionWithError.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            manager.delegate!.locationManager!(manager, rangingBeaconsDidFailFor: targetValue.0, withError: targetValue.1)
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

            _ = manager.rx.didVisit.subscribe(onNext: { n in
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
        let targetAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        #elseif os(iOS)
        let targetAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        #else
        let targetAuthorizationStatus = CLAuthorizationStatus.authorized
        #endif

        autoreleasepool {
            let manager = CLLocationManager()

            _ = manager.rx.didChangeAuthorizationStatus.subscribe(onNext: { status in
                    authorizationStatus = status
                }, onCompleted: {
                    completed = true
            })

            manager.delegate!.locationManager!(manager, didChangeAuthorization:targetAuthorizationStatus)
        }

        XCTAssertEqual(authorizationStatus, targetAuthorizationStatus)
        XCTAssertTrue(completed)
    }
}
