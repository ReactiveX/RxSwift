//
//  Observable+Creation.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// create

public func create<E>(subscribe: (ObserverOf<E>) -> Disposable) -> Observable<E> {
    return AnonymousObservable(subscribe)
}

// empty

public func empty<E>() -> Observable<E> {
    return AnonymousObservable { observer in
        sendCompleted(observer)
        return NopDisposable.instance
    }
}

// never

public func never<E>() -> Observable<E> {
    return AnonymousObservable { observer in
        return NopDisposable.instance
    }
}

// return

/**
The Just operator converts an item into an Observable that emits that item.

Just is similar to `From`, but note that `From` will dive into an array or an iterable or something of that sort to pull out items to emit, while `Just` will simply emit the array or iterable or what-have-you as it is, unchanged, as a single item.

- note: If you pass `nil` to `Just`, it will return an Observable that emits `nil` as an item. Do not make the mistake of assuming that this will return an empty Observable (one that emits no items at all). For that, you will need the `Empty` operator.

- seeAlso:
[ReactiveX.io/Just](http://reactivex.io/documentation/operators/just.html)

```Swift
// This example runs in a Playground
let oneObservable = just("Just this string please!")

let oneObservableSubscriber = oneObservable
    .subscribe { event in
        switch event {
        case .Next(let value):
        print("\(value)")
        case .Completed:
        print("completed")
        case .Error(let error):
        print("\(error)")
    }
```
- returns: an Observable that emits a particular item
*/
public func just<E>(value: E) -> Observable<E> {
    return AnonymousObservable { observer in
        sendNext(observer, value)
        sendCompleted(observer)
        return NopDisposable.instance
    }
}

public func sequenceOf<E>(values: E ...) -> Observable<E> {
    return AnonymousObservable { observer in
        for element in values {
            sendNext(observer, element)
        }
        
        sendCompleted(observer)
        return NopDisposable.instance
    }
}

public func from<E, S where S: SequenceType, S.Generator.Element == E>(sequence: S) -> Observable<E> {
    return AnonymousObservable { observer in
        for element in sequence {
            sendNext(observer, element)
        }
        
        sendCompleted(observer)
        return NopDisposable.instance
    }
}

// fail

public func failWith<E>(error: ErrorType) -> Observable<E> {
    return AnonymousObservable { observer in
        sendError(observer, error)
        return NopDisposable.instance
    }
}

// defer

public func deferred<E>(observableFactory: () throws -> Observable<E>)
    -> Observable<E> {
        return Deferred(observableFactory: observableFactory)
}