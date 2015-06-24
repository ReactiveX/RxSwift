

public func example(description: String, action: () -> ()) {
    println("\n--- \(description) example ---")
    action()
}
