//
//  Reactive.swift
//  Rx
//
//  Created by Yury Korolev on 5/2/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

/**
We can use `Reactive` protocol as customization point for constrained protocol extensions.

General pattern would be:


    // 1. Conform SomeType to Reactive protocol
    extension SomeType: Reactive {}

    // 2. Extend Reactive protocol with constrain on Self
    // Read as: Reactive Extension where Self is a SomeType
    extension Reactive where Self: SomeType {
        // 3. Put any specific reactive extension for SomeType here
    }


With this approach we can have more specialized methods and properties using 
`Self` and not just specialized on common base type.

See UIGestureRecognizer+Rx.swift as an example
*/

public protocol Reactive {
    
}
