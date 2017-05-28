//
//  ShareReplayScope.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/28/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

/// Subject lifetime scope
public enum SubjectLifetimeScope {
    /**
     **Each connection will have it's own subject instance to store replay events.**
     **Connections will be isolated from each another.**

     Configures the underlying implementation to behave equivalent to.
     
     ```
     source.multicast(makeSubject: { MySubject() }).refCount()
     ```

     **This is the recommended default.**

     This has the following consequences:
     * `retry` or `concat` operators will function as expected because terminating the sequence will clear internal state.
     * Each connection to source observable sequence will use it's own subject.
     * When the number of subscribers drops from 1 to 0 and connection to source sequence is disposed, subject will be cleared.

     
     ```
     let xs = Observable.deferred { () -> Observable<TimeInterval> in
             print("Performing work ...")
             return Observable.just(Date().timeIntervalSince1970)
         }
         .share(replay: 1, scope: .whileConnected)

     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })

     ```

     Notice how time interval is different and `Performing work ...` is printed each time)
     
     ```
     Performing work ...
     next 1495998900.82141
     completed

     Performing work ...
     next 1495998900.82359
     completed

     Performing work ...
     next 1495998900.82444
     completed


     ```
     
     */
    case whileConnected

    /**
     **One subject will store replay events for all connections to source.**
     **Connections won't be isolated from each another.**

     Configures the underlying implementation behave equivalent to.

     ```
     source.multicast(MySubject()).refCount()
     ```
     
     This has the following consequences:
     * Using `retry` or `concat` operators after this operator usually isn't advised.
     * Each connection to source observable sequence will share the same subject.
     * After number of subscribers drops from 1 to 0 and connection to source observable sequence is dispose, this operator will 
       continue holding a reference to the same subject.
       If at some later moment a new observer initiates a new connection to source it can potentially receive
       some of the stale events received during previous connection.
     * After source sequence terminates any new observer will always immediatelly receive replayed elements and terminal event.
       No new subscriptions to source observable sequence will be attempted.

     ```
     let xs = Observable.deferred { () -> Observable<TimeInterval> in
             print("Performing work ...")
             return Observable.just(Date().timeIntervalSince1970)
         }
         .share(replay: 1, scope: .forever)

     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     ```
     
     Notice how time interval is the same, replayed, and `Performing work ...` is printed only once
     
     ```
     Performing work ...
     next 1495999013.76356
     completed

     next 1495999013.76356
     completed

     next 1495999013.76356
     completed
     ```
     
    */
    case forever
}

extension ObservableType {

    /**
     Returns an observable sequence that **shares a single subscription to the underlying sequence**, and immediately upon subscription replays  elements in buffer.
     
     This operator is equivalent to:
     * `.whileConnected`
     ```
     // Each connection will have it's own subject instance to store replay events.
     // Connections will be isolated from each another.
     source.multicast(makeSubject: { Replay.create(bufferSize: replay) }).refCount()
     ```
     * `.forever`
     ```
     // One subject will store replay events for all connections to source.
     // Connections won't be isolated from each another.
     source.multicast(Replay.create(bufferSize: replay)).refCount()
     ```
     
     It uses optimized versions of the operators for most common operations.

     - parameter replay: Maximum element count of the replay buffer.
     - parameter scope: Lifetime scope of sharing subject. For more information see `SubjectLifetimeScope` enum.

     - seealso: [shareReplay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
     */
    public func share(replay: Int = 0, scope: SubjectLifetimeScope)
        -> Observable<E> {
        switch scope {
        case .forever:
            switch replay {
            case 0: return self.multicast(PublishSubject()).refCount()
            default: return shareReplay(replay)
            }
        case .whileConnected:
            switch replay {
            case 0: return self.multicast(makeSubject: { PublishSubject() }).refCount()
            case 1: return self.shareReplayLatestWhileConnected()
            default: return self.multicast(makeSubject: { ReplaySubject.create(bufferSize: replay) }).refCount()
            }
        }
    }
}
