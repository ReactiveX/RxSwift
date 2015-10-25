//
//  CoreMotion+Rx.swift
//  Rx
//
//  Created by Carlos García on 24/9/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//



import CoreMotion
import RxSwift


public extension CMMotionManager {
    
    var rx_acceleration: Observable<CMAcceleration> {
        return create { observer in
            if self.accelerometerAvailable {
                self.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: { (data: CMAccelerometerData?, error: NSError?) -> Void in
                    guard let data = data else {
                        return
                    }
                    observer.on(.Next(data.acceleration))
                })
            }
            
            return AnonymousDisposable {
                self.stopAccelerometerUpdates()
            }
            
        }
    }
    
    var rx_rotationRate: Observable<CMRotationRate> {
        return create { observer in
            if self.gyroAvailable {
                self.startGyroUpdatesToQueue(NSOperationQueue(), withHandler: { (data: CMGyroData?, error: NSError?) -> Void in
                    guard let data = data else {
                        return
                    }
                    observer.on(.Next(data.rotationRate))
                })
            }
            
            return AnonymousDisposable {
                self.stopGyroUpdates()
            }
        }
    }
    
    var rx_magneticField: Observable<CMMagneticField> {
        return create { observer in
            if self.magnetometerAvailable {
                self.startMagnetometerUpdatesToQueue(NSOperationQueue(), withHandler: { (data: CMMagnetometerData?, error: NSError?) -> Void in
                    guard let data = data else {
                        return
                    }
                    observer.on(.Next(data.magneticField))
                })
            }
            
            return AnonymousDisposable {
                self.stopMagnetometerUpdates()
            }
        }
    }
    
    var rx_deviceMotion: Observable<CMDeviceMotion> {
        return create { observer in
            if self.deviceMotionAvailable {
                self.startDeviceMotionUpdatesToQueue(NSOperationQueue(), withHandler: { (data: CMDeviceMotion?, error: NSError?) -> Void in
                    guard let data = data else {
                        return
                    }
                    observer.on(.Next(data))
                })
            }
            
            return AnonymousDisposable {
                self.stopDeviceMotionUpdates()
            }
        }
    }
    
    
}
