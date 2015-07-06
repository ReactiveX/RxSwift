

public func example(description: String, action: () -> ()) {
    print("\n--- \(description) example ---")
    action()
}
