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
    public func observe<Value>(_ keyPath: KeyPath<Base, Value>, options: KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> Observable<Value> {
        return KVOObservable(object: base, keyPath: keyPath, options: options, retainTarget: retainSelf)
            .asObservable()
    }

    public func observeWeakly<Value>(_ keyPath: KeyPath<Base, Value>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value?> {
        let observable = KVOObservable(object: base, keyPath: keyPath, options: options, retainTarget: false)
            .map { value -> Value? in value }
            .asObservable()
        return deallocating
            .map { _ in .just(nil) }
            .startWith(observable)
            .switchLatest()
    }

    public func observeWeakly<Value>(_ keyPath: KeyPath<Base, Value?>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value?> {
        let observable = KVOObservable(object: base, keyPath: keyPath, options: options, retainTarget: false)
            .asObservable()
        return deallocating
            .map { _ in .just(nil) }
            .startWith(observable)
            .switchLatest()
    }
}

extension Reactive where Base: NSObject {
    public func observeWeakly<Value, A: NSObject>(_ keyPath: KeyPath<Base, A?>, _ keyPath1: KeyPath<A, Value?>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value?> {
        return observeWeakly(keyPath, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath1, options: options) ?? .just(nil) }
    }
    public func observeWeakly<Value, A: NSObject>(_ keyPath: KeyPath<Base, A?>, _ keyPath1: KeyPath<A, Value>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value?> {
        return observeWeakly(keyPath, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath1, options: options) ?? .just(nil) }
    }
    public func observeWeakly<Value, A: NSObject>(_ keyPath: KeyPath<Base, A>, _ keyPath1: KeyPath<A, Value?>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value?> {
        return observeWeakly(keyPath, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath1, options: options) ?? .just(nil) }
    }
    public func observeWeakly<Value, A: NSObject>(_ keyPath: KeyPath<Base, A>, _ keyPath1: KeyPath<A, Value>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value?> {
        return observeWeakly(keyPath, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath1, options: options) ?? .just(nil) }
    }

    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath: KeyPath<Base, A?>,
        _ keyPath1: KeyPath<A, B?>,
        _ keyPath2: KeyPath<B, Value?>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        return observeWeakly(keyPath, keyPath1, options: options)
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options) ?? .just(nil) }
    }
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath: KeyPath<Base, A?>,
        _ keyPath1: KeyPath<A, B?>,
        _ keyPath2: KeyPath<B, Value>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        return observeWeakly(keyPath, keyPath1, options: options)
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options) ?? .just(nil) }
    }
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath: KeyPath<Base, A?>,
        _ keyPath1: KeyPath<A, B>,
        _ keyPath2: KeyPath<B, Value>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        return observeWeakly(keyPath, keyPath1, options: options)
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options) ?? .just(nil) }
    }
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath: KeyPath<Base, A>,
        _ keyPath1: KeyPath<A, B>,
        _ keyPath2: KeyPath<B, Value>,
        options: KeyValueObservingOptions = [.new, .initial]
        ) -> Observable<Value?> {
        return observeWeakly(keyPath, keyPath1, options: options)
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options) ?? .just(nil) }
    }
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath: KeyPath<Base, A>,
        _ keyPath1: KeyPath<A, B?>,
        _ keyPath2: KeyPath<B, Value?>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        return observeWeakly(keyPath, keyPath1, options: options)
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options) ?? .just(nil) }
    }
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath: KeyPath<Base, A>,
        _ keyPath1: KeyPath<A, B>,
        _ keyPath2: KeyPath<B, Value?>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        return observeWeakly(keyPath, keyPath1, options: options)
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options) ?? .just(nil) }
    }
}

private final class KVOObservable<Object: NSObject, Element>: ObservableType {
    typealias E = Element

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

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        let keyPath = self.keyPath
        var options = self.options
        let token = target.observe(keyPath, options: options.nsOptions) { (object, change) in
            if options.contains(.initial) {
                options.remove(.initial)
                observer.on(.next(object[keyPath: keyPath]))
            } else if options.contains(.new) {
                observer.on(.next(object[keyPath: keyPath]))
            }
        }
        return Disposables.create {
            token.invalidate()
            self.strongTarget = nil
        }
    }
}
