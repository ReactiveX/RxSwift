import Foundation

/**
 Encloses each code example in its own scope. Prints a `description` header and then executes the `action` closure.
 - parameter description: example description
 - parameter action: `Void` closure
 */
public func example(description: String, action: @noescape(Void) -> Void) {
    printExampleHeader(description: description)
    action()
}

public func printExampleHeader(description: String) {
    print("\n--- \(description) example ---")
}

public enum Error: ErrorProtocol {
    case test
}


/**
 Executes `closure` on main thread after `delay` seconds.
 - parameter delay: time in seconds to wait before executing `closure`
 - parameter closure: `Void` closure
 */
public func delay(delay: Double, closure: (Void) -> Void) {

    let delayTime = DispatchTime.now() + DispatchTimeInterval.seconds(Int(delay))
    DispatchQueue.main.after(when: delayTime) {
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
