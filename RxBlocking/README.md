RxBlocking 
============================================================

Set of blocking operators for easy unit testing.

***Don't use these operators in production apps. These operators are only meant for testing purposes.***


```swift
extension BlockingObservable {
    public func toArray() throws -> [E] {}
}

extension BlockingObservable {
    public func first() throws -> E? {}
}

extension BlockingObservable {
    public func last() throws -> E? {}
}

extension BlockingObservable {
    public func single() throws -> E? {}
    public func single(_ predicate: @escaping (E) throws -> Bool) throws -> E? {}
}

extension BlockingObservable {
    public func materialize() -> MaterializedSequenceResult<E>
}
```


