import Foundation

/**
 Encloses each code example in its own scope. Prints a `description` header and then executes the `action` closure.
 - parameter description: example description
 - parameter action: `Void` closure
 */
public func example(description: String, @noescape action: Void -> Void) {
    printExampleHeader(description)
    action()
}

public func printExampleHeader(description: String) {
    print("\n--- \(description) example ---")
}

public enum Error: ErrorType {
    case Test
}

/**
 Executes `closure` on main thread after `delay` seconds.
 - parameter delay: time in seconds to wait before executing `closure`
 - parameter closure: `Void` closure
 */
public func delay(delay: Double, closure: Void -> Void) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(),
        closure)
}

#if NOT_IN_PLAYGROUND
    
    public func playgroundShouldContinueIndefinitely() { }
    
#else
    
    import XCPlayground
    
    public func playgroundShouldContinueIndefinitely() {
        XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
    }
    
#endif
