//
//  AddRef.swift
//  RxSwift
//
//  Created by Junior B. on 30/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

final class AddRefSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Element = Observer.Element

    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            forwardOn(event)
        case .completed, .error:
            forwardOn(event)
            dispose()
        }
    }
}

final class AddRef<Element>: Producer<Element> {
    private let source: Observable<Element>
    private let refCount: RefCountDisposable

    init(source: Observable<Element>, refCount: RefCountDisposable) {
        self.source = source
        self.refCount = refCount
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let releaseDisposable = refCount.retain()
        let sink = AddRefSink(observer: observer, cancel: cancel)
        let subscription = Disposables.create(releaseDisposable, source.subscribe(sink))

        return (sink: sink, subscription: subscription)
    }
}
