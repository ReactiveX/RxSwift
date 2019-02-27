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
    public let source: ObservableSource<Element, Completed, Error>
    
    /// Observer type.
    public let observer: ObservableSource<Element, Completed, Error>.Observer
    
    public init(
        source: ObservableSource<Element, Completed, Error>,
        observer: @escaping ObservableSource<Element, Completed, Error>.Observer
    ) {
        self.source = source
        self.observer = observer
    }
    
    @inline(__always)
    public func subscribe(_ observer: @escaping ObservableSource<Element, Completed, Error>.Observer) -> Disposable {
        return source.subscribe(observer)
    }
}

extension Subject: ObservableType {
    public func asSource() -> ObservableSource<Element, Completed, Error> {
        return source
    }
}

public typealias SubjectType = Subject
