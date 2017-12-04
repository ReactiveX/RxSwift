import Dispatch

/**
 Encloses each code example in its own scope. Prints a `description` header and then executes the `action` closure.
 - parameter description: example description
 - parameter action: `Void` closure
 */
public func example(_ description: String, action: () -> Void) {
    printExampleHeader(description)
    action()
}

public func printExampleHeader(_ description: String) {
    print("\n--- \(description) example ---")
}

public enum TestError: Swift.Error {
    case test
}


/**
 Executes `closure` on main thread after `delay` seconds.
 - parameter delay: time in seconds to wait before executing `closure`
 - parameter closure: `Void` closure
 */
public func delay(_ delay: Double, closure: @escaping () -> Void) {

    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

#if NOT_IN_PLAYGROUND
    
    public func playgroundShouldContinueIndefinitely() { }
    
#else
    
    import PlaygroundSupport
    
    public func playgroundShouldContinueIndefinitely() {
        PlaygroundPage.current.needsIndefiniteExecution = true
    }
    
#endif
