//
//  SubjectType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents an object that is both an observable sequence as well as an observer.
public struct Subject<Element, Completed, Error> {
    /// Observable source.
    let source: ObservableSource<Element, Completed, Error>
    
    /// Observer type.
    let observer: ObservableSource<Element, Completed, Error>.Observer
}

extension Subject {
    /// Returns observer interface for subject.
    ///
    /// - returns: Observer interface for subject.
    public func asObserver() -> ObservableSource<Element, Completed, Error>.Observer {
        return observer
    }
}

public typealias SubjectType = Subject
