//
//  ReachabilityService.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 22.10.2015.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
#endif

public enum ReachabilityStatus{
    case Reachable, Unreachable
}

class ReachabilityService{

    private let reachabilityRef = try! Reachability.reachabilityForInternetConnection()

    private let _reachabilityChangedSubject = PublishSubject<ReachabilityStatus>()
    private var reachabilityChanged: Observable<ReachabilityStatus> {
        get {
            return _reachabilityChangedSubject.asObservable()
        }
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
    func retryOnBecomesReachable(valueOnFailure:E, reachabilityService: ReachabilityService) -> Observable<E>{
        return retryOnBecomesReachable(valueOnFailure, reachabilityService: reachabilityService, orExternalTrigger: empty())
    }

    func retryOnBecomesReachable(valueOnFailure:E, reachabilityService:ReachabilityService, orExternalTrigger: Observable<Void>) -> Observable<E>{
        return self.asObservable()
            .catchError { (e) -> Observable<E> in
                let retryBecauseOfNeworkAvailability = reachabilityService.reachabilityChanged
                    .flatMap { event -> Observable<Void> in
                        if event == .Reachable {
                            return just()
                        } else {
                            return empty()
                        }
                    }

                return sequenceOf(retryBecauseOfNeworkAvailability, orExternalTrigger)
                    .merge()
                    .flatMap { _ in failWith(e) }
                    .startWith(valueOnFailure)
            }
            .retry()
    }
}
