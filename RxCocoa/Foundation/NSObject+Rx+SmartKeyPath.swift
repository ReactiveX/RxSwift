//
//  NSObject+Rx+SmartKeyPath.swift
//  RxCocoa
//
//  Created by Hayashi Tatsuya on 12/24/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation.NSObject
import RxSwift

extension Reactive where Base: NSObject {
    /**
     Observes values on `keyPath` starting from `self` with `options` and retains `self` if `retainSelf` is set.

     `observe` is just a simple and performant wrapper around KVO mechanism.

     * it can be used to observe paths starting from `self` or from ancestors in ownership graph (`retainSelf = false`)
     * it can be used to observe paths starting from descendants in ownership graph (`retainSelf = true`)
     * the paths have to consist only of `strong` properties, otherwise you are risking crashing the system by not unregistering KVO observer before dealloc.

     If support for weak properties is needed or observing arbitrary or unknown relationships in the
     ownership tree, `observeWeakly` is the preferred option.

     - parameter keyPath: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - parameter retainSelf: Retains self during observation if set `true`.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observe<Value>(_ keyPath: KeyPath<Base, Value>, options: KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> Observable<Value> {
        return KVOObservable(object: base, keyPath: keyPath, options: options, retainTarget: retainSelf)
            .asObservable()
    }
}

#if !DISABLE_SWIZZLING && !os(Linux)
extension Reactive where Base: NSObject {
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     - parameter keyPath: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value>(_ keyPath: KeyPath<Base, Value>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value?> {
        let observable = KVOObservable(object: base, keyPath: keyPath, options: options, retainTarget: false)
            .map { value -> Value? in value }
            .asObservable()
        return deallocating
            .map { _ in .just(nil) }
            .startWith(observable)
            .switchLatest()
    }

    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     - parameter keyPath: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
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
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject>(
        _ keyPath0: KeyPath<Base, A?>,
        _ keyPath1: KeyPath<A, Value?>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath1, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject>(
        _ keyPath0: KeyPath<Base, A?>,
        _ keyPath1: KeyPath<A, Value>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath1, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject>(
        _ keyPath0: KeyPath<Base, A>,
        _ keyPath1: KeyPath<A, Value?>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath1, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject>(
        _ keyPath0: KeyPath<Base, A>,
        _ keyPath1: KeyPath<A, Value>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath1, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
}

extension Reactive where Base: NSObject {
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath0: KeyPath<Base, A?>,
        _ keyPath1: KeyPath<A, B?>,
        _ keyPath2: KeyPath<B, Value?>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, keyPath1, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath0: KeyPath<Base, A?>,
        _ keyPath1: KeyPath<A, B?>,
        _ keyPath2: KeyPath<B, Value>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, keyPath1, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath0: KeyPath<Base, A?>,
        _ keyPath1: KeyPath<A, B>,
        _ keyPath2: KeyPath<B, Value?>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, keyPath1, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath0: KeyPath<Base, A?>,
        _ keyPath1: KeyPath<A, B>,
        _ keyPath2: KeyPath<B, Value>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, keyPath1, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath0: KeyPath<Base, A>,
        _ keyPath1: KeyPath<A, B?>,
        _ keyPath2: KeyPath<B, Value?>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, keyPath1, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath0: KeyPath<Base, A>,
        _ keyPath1: KeyPath<A, B?>,
        _ keyPath2: KeyPath<B, Value>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, keyPath1, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath0: KeyPath<Base, A>,
        _ keyPath1: KeyPath<A, B>,
        _ keyPath2: KeyPath<B, Value?>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, keyPath1, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     `NSObject.observe` cannot detect ARC zeroing weak reference.
     If you want to observe chaining keyPath with weakly, use this method.

     ```
     object.rx.observeWeakly(\.weakValue?.value)
     ↓
     object.rx.observeWeakly(\.weakValue, \.value)
     ```

     - parameter keyPath0: Key path of property to observe.
     - parameter keyPath1: Key path of property to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    public func observeWeakly<Value, A: NSObject, B: NSObject>(
        _ keyPath0: KeyPath<Base, A>,
        _ keyPath1: KeyPath<A, B>,
        _ keyPath2: KeyPath<B, Value>,
        options: KeyValueObservingOptions = [.new, .initial]
    ) -> Observable<Value?> {
        let observable = observeWeakly(keyPath0, keyPath1, options: options.union(.initial))
            .flatMap { $0?.rx.observeWeakly(keyPath2, options: options.union(.initial)) ?? .just(nil) }
        return !options.contains(.initial) ? observable.skip(1) : observable
    }
}
#endif

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
