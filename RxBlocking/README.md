RxBlocking 
============================================================

Set of blocking operators for easy unit testing.

***Don't use these operators in production apps. These operators are only meant for testing purposes.***


```swift
public func toArray<E>(source: Observable<E>)
    -> RxResult<[E]> {}

public func first<E>(source: Observable<E>)
    -> RxResult<E?> {}

public func last<E>(source: Observable<E>)
    -> RxResult<E?> {}
```


