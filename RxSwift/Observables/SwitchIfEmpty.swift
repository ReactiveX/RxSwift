//
//  SwitchIfEmpty.swift
//  RxSwift
//
//  Created by sergdort on 23/12/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     Returns the elements of the specified sequence or `switchTo` sequence if the sequence is empty.

     - seealso: [DefaultIfEmpty operator on reactivex.io](http://reactivex.io/documentation/operators/defaultifempty.html)

     - parameter switchTo: Observable sequence being returned when source sequence is empty.
     - returns: Observable sequence that contains elements from switchTo sequence if source is empty, otherwise returns source sequence elements.
     */
    public func ifEmpty(switchTo other: Observable<E>) -> Observable<E> {
        return SwitchIfEmpty(source: asObservable(), ifEmpty: other)
    }
}

final fileprivate class SwitchIfEmpty<Element>: Producer<Element> {
    
    private let _source: Observable<E>
    private let _ifEmpty: Observable<E>
    
    init(source: Observable<E>, ifEmpty: Observable<E>) {
        _source = source
        _ifEmpty = ifEmpty
    }
    
    override func run(_ observer: @escaping (Event<E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = SwitchIfEmptySink(ifEmpty: _ifEmpty,
                                     observer: observer,
                                     cancel: cancel)
        let subscription = sink.run(_source.asObservable())
        
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class SwitchIfEmptySink<Element>: Sink<Element> {
    private let _ifEmpty: Observable<Element>
    private var _isEmpty = true
    private let _ifEmptySubscription = SingleAssignmentDisposable()
    
    init(ifEmpty: Observable<Element>, observer: @escaping (Event<Element>) -> (), cancel: Cancelable) {
        _ifEmpty = ifEmpty
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(_ source: Observable<Element>) -> Disposable {
        let subscription = source.subscribe { event in
            switch event {
            case .next:
                self._isEmpty = false
                self.forwardOn(event)
            case .error:
                self.forwardOn(event)
                self.dispose()
            case .completed:
                guard self._isEmpty else {
                    self.forwardOn(.completed)
                    self.dispose()
                    return
                }
                self._ifEmptySubscription.setDisposable(self._ifEmpty.subscribe { event in
                    switch event {
                    case .next:
                        self.forwardOn(event)
                    case .error:
                        self.forwardOn(event)
                        self.dispose()
                    case .completed:
                        self.forwardOn(event)
                        self.dispose()
                    }
                })
            }
        }
        return Disposable.create(subscription, _ifEmptySubscription)
    }
}
