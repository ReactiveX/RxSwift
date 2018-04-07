//
//  TimeInterval.swift
//
//  Created by Ayal Spitz on 4/4/18.
//

import Foundation

extension ObservableType {
    public func timeInterval() -> Observable<RxTimeInterval> {
        return TimeInterval(source: asObservable())
    }
}

final fileprivate class TimeInterval<SourceType> : Producer<RxTimeInterval> {
    let source: Observable<SourceType>
    var subscribeTime: RxTimeInterval
    
    init(source: Observable<SourceType>) {
        subscribeTime = Date.timeIntervalSinceReferenceDate
        self.source = source
    }
    
    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == RxTimeInterval {
        return super.subscribe(observer)
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == RxTimeInterval {
        let sink = TimeIntervalSink(parent: self, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class TimeIntervalSink<SourceType, O : ObserverType> : Sink<O>, ObserverType where O.E == RxTimeInterval {
    typealias Parent = TimeInterval<SourceType>
    var time: RxTimeInterval
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        self.time = parent.subscribeTime
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<SourceType>) {
        switch event {
        case .next:
            let now = Date.timeIntervalSinceReferenceDate
            let timeInterval = now - time
            self.time = now
            forwardOn(.next(timeInterval))
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
    
}
