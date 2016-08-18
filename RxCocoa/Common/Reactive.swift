//
//  Reactive.swift
//  Rx
//
//  Created by Yury Korolev on 5/2/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

/**
 Use `Reactive` proxy as customization point for constrained protocol extensions.

 General pattern would be:

 // 1. Extend Reactive protocol with constrain on Self
 // Read as: Reactive Extension where Self is a SomeType
 extension Reactive where Self: SomeType {
 // 2. Put any specific reactive extension for SomeType here
 }

 With this approach we can have more specialized methods and properties using
 `Self` and not just specialized on common base type.

 */

public struct Reactive<Base> {
    /**
    Base object to extend.
    */
    public let base: Base

    /**
     Creates extensions with base object.
     
     - parameter base: Base object.
    */
    public init(_ base: Base) {
        self.base = base
    }
}

/**
 A type that has reactive extensions.
 */
public protocol ReactiveCompatible {
    associatedtype CompatibleType
    var rx: Reactive<CompatibleType> { get }
}

public extension ReactiveCompatible {
    public var rx: Reactive<Self> {
        return Reactive(self)
    }
}

/**
 Extend NSObject with `rx` proxy.
*/
extension NSObject: ReactiveCompatible { }
