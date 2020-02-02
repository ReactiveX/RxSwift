//
//  Pairwise.swift
//  RxSwift
//
//  Created by Ihor Vovk on 2/2/20.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Emits a pair of last two elements for every element from the observable sequence starting from the second one.

     - returns: An observable sequence that emits pairs of last two elements from the observable sequence.
     */
    public func pairwise()
        -> Observable<(Element, Element)> {
        Pairwise(source: self.asObservable())
    }
}

final private class PairwiseSink<SourceType, Observer: ObserverType>: Sink<Observer>, ObserverType where Observer.Element == (SourceType, SourceType) {
    typealias Element = SourceType
    
    var previousElement: Element?
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let element):
            if let previousElement = previousElement {
                self.forwardOn(.next((previousElement, element)))
            }
            
            self.previousElement = element
        case .error(let error):
            self.forwardOn(.error(error))
            self.dispose()
        case .completed:
            self.forwardOn(.completed)
            self.dispose()
        }
    }
}

final private class Pairwise<SourceType>: Producer<(SourceType, SourceType)> {
    let source: Observable<SourceType>
    
    init(source: Observable<SourceType>) {
        self.source = source
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = PairwiseSink(observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
