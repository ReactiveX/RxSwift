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
    case Reachable(viaWiFi: Bool)
    case Unreachable
}

extension ReachabilityStatus {
    var reachable: Bool {
        switch self {
        case .Reachable:
            return true
        case .Unreachable:
            return false
        }
    }
}

protocol ReachabilityService {
    var reachability: Observable<ReachabilityStatus> { get }
}

class DefaultReachabilityService
    : ReachabilityService {

    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>

    var reachability: Observable<ReachabilityStatus> {
        return _reachabilitySubject.asObservable()
    }

    let _reachability: Reachability

    init() throws {
        let reachabilityRef = try Reachability.reachabilityForInternetConnection()
        let reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .Unreachable)

        reachabilityRef.whenReachable = { reachability in
            reachabilitySubject.on(.Next(.Reachable(viaWiFi: reachabilityRef.isReachableViaWiFi())))
        }

        reachabilityRef.whenUnreachable = { reachability in
            reachabilitySubject.on(.Next(.Unreachable))
        }

        try reachabilityRef.startNotifier()
        _reachability = reachabilityRef
        _reachabilitySubject = reachabilitySubject
    }

    deinit {
        _reachability.stopNotifier()
    }
}

extension ObservableConvertibleType {
    func retryOnBecomesReachable(valueOnFailure:E, reachabilityService: ReachabilityService) -> Observable<E> {
        return self.asObservable()
            .catchError { (e) -> Observable<E> in
                reachabilityService.reachability
                    .filter { $0.reachable }
                    .flatMap { _ in Observable.error(e) }
                    .startWith(valueOnFailure)
            }
            .retry()
    }
}
