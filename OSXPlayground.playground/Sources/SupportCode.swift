

public func example(description: String, action: () -> ()) {
    println("--- \(description) example ---")
    action()
}