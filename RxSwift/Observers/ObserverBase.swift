//
//  ObserverBase.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableSource {
//    class ObserverBase: Disposable {
//        typealias E = ElementType
//
//        func on(_ event: Event<Element, Completed, Error>) {
//            switch event {
//            case .next:
//                if load(&self._isStopped) == 0 {
//                    self.onCore(event)
//                }
//            case .error, .completed:
//                if fetchOr(&self._isStopped, 1) == 0 {
//                    self.onCore(event)
//                }
//            }
//        }
//
//        func onCore(_ event: Event<Element, Completed, Error>) {
//            rxAbstractMethod()
//        }
//
//        func dispose() {
//            fetchOr(&self._isStopped, 1)
//        }
//    }
}
