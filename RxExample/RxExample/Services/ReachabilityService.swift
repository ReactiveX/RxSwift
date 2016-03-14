//
//  ReachabilityService.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 10/22/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
#endif

public enum ReachabilityStatus {
    case Reachable, Unreachable
}

class ReachabilityService {

    private let reachabilityRef = try! Reachability.reachabilityForInternetConnection()

    private let _reachabilityChangedSubject = PublishSubject<ReachabilityStatus>()
    private var reachabilityChanged: Observable<ReachabilityStatus> {
        return _reachabilityChangedSubject.asObservable()
    }

    // singleton
    static let sharedReachabilityService = ReachabilityService()

    init(){
        reachabilityRef.whenReachable = { reachability in
            self._reachabilityChangedSubject.on(.Next(.Reachable))
        }

        reachabilityRef.whenUnreachable = { reachability in
            self._reachabilityChangedSubject.on(.Next(.Unreachable))
        }

        try! reachabilityRef.startNotifier()

    }
}

extension ObservableConvertibleType {
    func retryOnBecomesReachable(valueOnFailure:E, reachabilityService: ReachabilityService) -> Observable<E> {
        return self.asObservable()
            .catchError { (e) -> Observable<E> in
                reachabilityService.reachabilityChanged
                    .filter { $0 == .Reachable }
                    .flatMap { _ in Observable.error(e) }
                    .startWith(valueOnFailure)
            }
            .retry()
    }
}
