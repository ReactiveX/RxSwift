//
//  Maybe.swift
//  Rx
//
//  Created by sergdort on 19/08/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

/// Sequence containing 0 or 1 elements
public enum MaybeTrait { }
/// Represents a push style sequence containing 0 or 1 element.
public typealias Maybe<Element> = PrimitiveSequence<MaybeTrait, Element>

public enum MaybeEvent<Element> {
    /// One and only sequence element is produced. (underlying observable sequence emits: `.next(Element)`, `.completed`)
    case success(Element)
    
    /// Sequence terminated with an error. (underlying observable sequence emits: `.error(Error)`)
    case error(Swift.Error)
    
    /// Sequence completed successfully.
    case completed
}

public extension PrimitiveSequenceType where TraitType == MaybeTrait {
    public typealias MaybeObserver = (MaybeEvent<ElementType>) -> ()
    
    /**
     Creates an observable sequence from a specified subscribe method implementation.
     
     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)
     
     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
    public static func create(subscribe: @escaping (@escaping MaybeObserver) -> Disposable) -> PrimitiveSequence<TraitType, ElementType> {
        let source = Observable<ElementType>.create { observer in
            return subscribe { event in
                switch event {
                case .success(let element):
                    observer.on(.next(element))
                    observer.on(.completed)
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
        }
        
        return PrimitiveSequence(raw: source)
    }
    
    /**
     Subscribes `observer` to receive events for this sequence.
     
     - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
     */
    public func subscribe(_ observer: @escaping (MaybeEvent<ElementType>) -> ()) -> Disposable {
        var stopped = false
        return self.primitiveSequence.asObservable().subscribe { event in
            if stopped { return }
            stopped = true
            
            switch event {
            case .next(let element):
                observer(.success(element))
            case .error(let error):
                observer(.error(error))
            case .completed:
                observer(.completed)
            }
        }
    }
    
    /**
     Subscribes a success handler, an error handler, and a completion handler for this sequence.
     
     - parameter onSuccess: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    public func subscribe(onSuccess: ((ElementType) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil) -> Disposable {
        return self.primitiveSequence.subscribe { event in
            switch event {
            case .success(let element):
                onSuccess?(element)
            case .error(let error):
                onError?(error)
            case .completed:
                onCompleted?()
            }
        }
    }
}
