RxBlocking 
============================================================

Set of blocking operators for easy unit testing.

***Don't use these operators in production apps. These operators are only meant for testing purposes.***


```swift
extension ObservableType {
    public func toArray() throws -> [E] {}
}

extension ObservableType {
    public func first() throws -> E? {}
}

extension ObservableType {
    public func last() throws -> E? {}
}
```


