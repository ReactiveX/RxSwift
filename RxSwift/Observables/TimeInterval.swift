//
//  TimeInterval.swift
//
//  Created by Ayal Spitz on 4/4/18.
//

import Foundation

extension ObservableType {
    public func timeInterval(roundRule: FloatingPointRoundingRule? = nil) -> Observable<RxTimeInterval> {
        return TimeInterval(source: asObservable(), roundRule: roundRule)
    }
}

final fileprivate class TimeInterval<SourceType> : Producer<RxTimeInterval> {
    let source: Observable<SourceType>
    let roundRule: FloatingPointRoundingRule?
    var subscribeTime: RxTimeInterval
    
    init(source: Observable<SourceType>, roundRule: FloatingPointRoundingRule? = nil) {
        subscribeTime = Date.timeIntervalSinceReferenceDate
        self.source = source
        self.roundRule = roundRule
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
    let roundRule: FloatingPointRoundingRule?
    var time: RxTimeInterval

    init(parent: Parent, observer: O, cancel: Cancelable) {
        roundRule = parent.roundRule
        time = parent.subscribeTime
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<SourceType>) {
        switch event {
        case .next:
            let now = Date.timeIntervalSinceReferenceDate
            let timeInterval: RxTimeInterval
            if let roundRule = roundRule {
                timeInterval = (now - time).rounded(roundRule)
            } else {
                timeInterval = now - time
            }
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
