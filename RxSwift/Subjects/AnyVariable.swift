//
//  AnyVariable.swift
//  Rx
//
//  Created by Ilya Laryionau on 20/05/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

/**
 AnyVariable is a wrapper for `Variable`.
 
 Unlike `Variable` its value is read-only, and when variable is deallocated
 it will complete it's observable sequence (`asObservable`).
 */
public class AnyVariable<Element>: VariableType, ObservableConvertibleType {
    
    public typealias E = Element
    
    private let _variable: Variable<Element>
    private let _disposeBag: DisposeBag = DisposeBag()
    
    /**
     Gets current value of variable.
     
     Whenever a new value is set, all the observers are notified of the change.
     
     Even if the newly set value is same as the old value, observers are still notified for change.
     */
    public var value: E {
        get {
            return _variable.value
        }
    }
    
    /**
     Initializes a property that first takes on `initialValue`, then each value
     
     sent on an event created by `observable`.
     */
    public init(initialValue: E, observable: Observable<E>) {
        _variable = Variable(initialValue)
        
        observable
            .subscribeNext { [weak self] in
                self?._variable.value = $0
            }
            .addDisposableTo(_disposeBag)
    }
    
    /**
     - returns: Canonical interface for push style sequence
     */
    public func asObservable() -> Observable<E> {
        return _variable.asObservable()
    }
}
