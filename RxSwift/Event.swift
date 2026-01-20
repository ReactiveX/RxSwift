//
//  Event.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a sequence event.
///
/// Sequence grammar:
/// **next\* (error | completed)**
@frozen public enum Event<Element> {
    /// Next element is produced.
    case next(Element)

    /// Sequence terminated with an error.
    case error(Swift.Error)

    /// Sequence completed successfully.
    case completed
}

extension Event: CustomDebugStringConvertible {
    /// Description of event.
    public var debugDescription: String {
        switch self {
        case let .next(value):
            "next(\(value))"
        case let .error(error):
            "error(\(error))"
        case .completed:
            "completed"
        }
    }
}

public extension Event {
    /// Is `completed` or `error` event.
    var isStopEvent: Bool {
        switch self {
        case .next: false
        case .error, .completed: true
        }
    }

    /// If `next` event, returns element value.
    var element: Element? {
        if case let .next(value) = self {
            return value
        }
        return nil
    }

    /// If `error` event, returns error.
    var error: Swift.Error? {
        if case let .error(error) = self {
            return error
        }
        return nil
    }

    /// If `completed` event, returns `true`.
    var isCompleted: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
}

public extension Event {
    /// Maps sequence elements using transform. If error happens during the transform, `.error`
    /// will be returned as value.
    func map<Result>(_ transform: (Element) throws -> Result) -> Event<Result> {
        do {
            switch self {
            case let .next(element):
                return try .next(transform(element))
            case let .error(error):
                return .error(error)
            case .completed:
                return .completed
            }
        } catch let e {
            return .error(e)
        }
    }
}

/// A type that can be converted to `Event<Element>`.
public protocol EventConvertible {
    /// Type of element in event
    associatedtype Element

    /// Event representation of this instance
    var event: Event<Element> { get }
}

extension Event: EventConvertible {
    /// Event representation of this instance
    public var event: Event<Element> { self }
}
