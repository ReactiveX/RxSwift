//
//  IgnoreCompleted.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/25/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    public func ignoreCompleted<AnyCompleted>(_ completedType: AnyCompleted.Type = AnyCompleted.self)
        -> ObservableSource<Element, AnyCompleted, Error> {
        let source = self.source
        return ObservableSource(run: .run { nextObserver, cancel in
            let observer: ObservableSource<Element, Completed, Error>.Observer = { event in
                switch event {
                case .next(let element):
                    nextObserver(.next(element))
                case .completed:
                    break
                case .error(let error):
                    nextObserver(.error(error))
                }
            }
            return source.run(observer, cancel)
        })
    }
}

extension ObservableType where Completed == Never, Error == Never {
    public func ignoreCompletedAndError<AnyCompleted, AnyError>()
        -> ObservableSource<Element, AnyCompleted, AnyError> {
        let source = self.source
        return ObservableSource(run: .run { nextObserver, cancel in
            let observer: ObservableSource<Element, Completed, Error>.Observer = { event in
                switch event {
                case .next(let element):
                    nextObserver(.next(element))
                }
            }
            return source.run(observer, cancel)
        })
    }
}

