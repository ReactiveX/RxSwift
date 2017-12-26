//
//  NSObject+Rx+SmartKeyPath.swift
//  RxSwift-iOS
//
//  Created by Hayashi Tatsuya on 12/24/17.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import Foundation.NSObject
import RxSwift

extension Reactive where Base: NSObject {
    public func observe<Value>(_ keyPath: KeyPath<Base, Value>, options: KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> Observable<Value?> {
        return KVOObservable(object: base, keyPath: keyPath, options: options, retainTarget: retainSelf).asObservable()
    }

    public func observeWeakly<Value>(_ keyPath: KeyPath<Base, Value>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value?> {
        let observable = KVOObservable(object: base, keyPath: keyPath, options: options, retainTarget: false)
            .asObservable()
        return deallocating
            .map { _ in .just(nil) }
            .startWith(observable)
            .switchLatest()
    }

    public func observeWeakly<Value>(_ keyPath: KeyPath<Base, Value?>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value?> {
        let observable = KVOObservable(object: base, keyPath: keyPath, options: options, retainTarget: false)
            .asObservable()
            .map { $0 ?? nil }
        return deallocating
            .map { _ in .just(nil) }
            .startWith(observable)
            .switchLatest()
    }
}


private final class KVOObservable<Object: NSObject, Element>: ObservableType {
    typealias E = Element?

    unowned var target: Object
    var strongTarget: Object?
    var keyPath: KeyPath<Object, Element>
    var options: KeyValueObservingOptions
    var retainTarget: Bool

    init(object: Object, keyPath: KeyPath<Object, Element>, options: KeyValueObservingOptions, retainTarget: Bool) {
        self.target = object
        self.keyPath = keyPath
        self.options = options
        self.retainTarget = retainTarget
        if retainTarget {
            self.strongTarget = object
        }
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == Element? {
        let token = target.observe(keyPath, options: options.nsOptions) { (object, change) in
            observer.on(.next(change.newValue))
        }
        return Disposables.create {
            token.invalidate()
        }
    }
}
