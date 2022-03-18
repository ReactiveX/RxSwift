//
//  ObservableType+Record.swift
//  
//
//  Created by dongyoung.lee on 2022/03/19.
//

import RxSwift
import Foundation

extension ObservableType {
    /// Converts an `Observable` that records last `N` events
    ///
    /// - parameter bufferSize: Number of recent recordable events
    /// - returns: `Observable<Element>` version of `self`
    func recorded(_ bufferSize: Int = 10) -> Observable<Element> {
        let replaySubject = ReplaySubject<Element>.create(bufferSize: bufferSize)
        _ = self.subscribe(replaySubject)
        return replaySubject.asObservable()
    }
}
