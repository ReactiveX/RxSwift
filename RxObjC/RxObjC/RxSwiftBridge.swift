//
//  RxSwiftBridge.swift
//  RxObjC
//
//  Created by Krunoslav Zaher on 7/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

extension ObserverOf {
    func toRxObserver() -> RXObserver {
        return RXObserver(onNext: { (element) -> Void in
            self.on(.Next(element as! ElementType))
            }, onError: { (error) -> Void in
                self.on(.Error(error))
            }, onCompleted: { () -> Void in
                self.on(.Completed)
        })
    }
}

extension Observable {
    public func toRxObservable() -> RXObservable {
        return RXObservable._createWithSwiftObservable(self)
    }
}

extension Disposable {
    func toRxDisposable() -> RXDisposable {
        return RXDisposable {
            self.dispose()
        }
    }
}


func o(objcObservable: RXObservable) -> Observable<AnyObject> {
    return objcObservable.swiftObservable as! Observable<AnyObject>
}

extension RXObservable {

    //public class func createRxObservable(objcSubscribe: (observer: RXObserver) -> RXDisposable) -> RXObservable {
    public class func createRxObservable(objcSubscribe: RXObservableSubscribe) -> RXObservable {
        let swiftObservable: Observable<AnyObject> = create { observer in
            let swiftDisposable = objcSubscribe(observer.toRxObserver())
            return AnonymousDisposable {
                swiftDisposable.dispose()
            }
        }
        
        return swiftObservable.toRxObservable()
    }
    
    public class func map(function: RxMap) -> RXObservable {
        return (nil as RXObservable?)!
    }
}

// standard sequence operators

extension RXObservable {
    
    public var _map: (RxMap!) -> RXObservable! {
        get {
            return { (objc: RxMap!) in
                let observable = o(self) >- RxSwift.map { (se: AnyObject) -> AnyObject in
                    return objc(se)
                }
                    
                return observable.toRxObservable()
            }
        }
    }
    
    public var _filter: (RxFilter!) -> RXObservable! {
        get {
            return { (objc: RxFilter!) in
                let observable = o(self) >- RxSwift.filter { (se: AnyObject) -> Bool in
                    return objc(se)
                }
                
                return observable.toRxObservable()
            }
        }
    }
}

// subscription

extension RXObservable {
    public var _subscribeNext: (ObserverOnNext!) -> RXDisposable! {
        get {
            return { (objc: ObserverOnNext!) in
                let disposable = o(self) >- RxSwift.subscribeNext({ e -> Void in
                    objc(e)
                })
                
                return disposable.toRxDisposable()
            }
        }
    }
    
    public var _subscribe: (ObserverOnNext!) -> RXDisposable! {
        get {
            return { (objc: ObserverOnNext!) in
                let disposable = o(self) >- RxSwift.subscribeNext({ e -> Void in
                    objc(e)
                })
                
                return disposable.toRxDisposable()
            }
        }
    }
}