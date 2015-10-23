//
//  Reachability+Rx.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 22.10.2015.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

public enum ReachabilityStatus{
    case Reachable,Unreachable
}

extension Reachability{

    /**
    Reactive wrapper for reachability state changes
    */
    public var rx_reachable: Observable<ReachabilityStatus> {

        return create { observer in

            self.whenReachable = { reachability in
                observer.on(.Next(.Reachable))
            }
            self.whenUnreachable = { reachability in
                observer.on(.Next(.Unreachable))
            }
            do{
                try self.startNotifier()
            }catch let error{
                observer.on(.Error(error))
            }
            return NopDisposable.instance
        }

    }
}