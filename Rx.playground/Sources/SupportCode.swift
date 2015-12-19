
import Foundation

public func example(description: String, action: () -> ()) {
    print("\n--- \(description) example ---")
    action()
}

public func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

#if NOT_IN_PLAYGROUND

public func playgroundShouldContinueIndefinitely() {
}

#else

import XCPlayground

public func playgroundShouldContinueIndefinitely() {
    XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
}

#endif
