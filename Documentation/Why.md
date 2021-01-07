## Why

**Rx enables building apps in a declarative way.**

### Bindings

```swift
Observable.combineLatest(firstName.rx.text, lastName.rx.text) { $0 + " " + $1 }
    .map { "Greetings, \($0)" }
    .bind(to: greetingLabel.rx.text)
```

This also works with `UITableView`s and `UICollectionView`s.

```swift
viewModel
    .rows
    .bind(to: resultsTableView.rx.items(cellIdentifier: "WikipediaSearchCell", cellType: WikipediaSearchCell.self)) { (_, viewModel, cell) in
        cell.title = viewModel.title
        cell.url = viewModel.url
    }
    .disposed(by: disposeBag)
```

**Official suggestion is to always use `.disposed(by: disposeBag)` even though that's not necessary for simple bindings.**

### Retries

It would be great if APIs wouldn't fail, but unfortunately they do. Let's say there is an API method:

```swift
func doSomethingIncredible(forWho: String) throws -> IncredibleThing
```

If you are using this function as it is, it's really hard to do retries in case it fails. Not to mention complexities modeling [exponential backoffs](https://en.wikipedia.org/wiki/Exponential_backoff). Sure it's possible, but the code would probably contain a lot of transient states that you really don't care about, and it wouldn't be reusable.

Ideally, you would want to capture the essence of retrying, and to be able to apply it to any operation.

This is how you can do simple retries with Rx

```swift
doSomethingIncredible("me")
    .retry(3)
```

You can also easily create custom retry operators.

### Delegates

Instead of doing the tedious and non-expressive:

```swift
public func scrollViewDidScroll(scrollView: UIScrollView) { [weak self] // what scroll view is this bound to?
    self?.leftPositionConstraint.constant = scrollView.contentOffset.x
}
```

... write

```swift
self.resultsTableView
    .rx.contentOffset
    .map { $0.x }
    .bind(to: self.leftPositionConstraint.rx.constant)
```

### KVO

Instead of:

```
`TickTock` was deallocated while key value observers were still registered with it. Observation info was leaked, and may even become mistakenly attached to some other object.
```

and

```objc
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
```

Use [`rx.observe` and `rx.observeWeakly`](GettingStarted.md#kvo)

This is how they can be used:

```swift
view.rx.observe(CGRect.self, "frame")
    .subscribe(onNext: { frame in
        print("Got new frame \(frame)")
    })
    .disposed(by: disposeBag)
```

or

```swift
someSuspiciousViewController
    .rx.observeWeakly(Bool.self, "behavingOk")
    .subscribe(onNext: { behavingOk in
        print("Cats can purr? \(behavingOk)")
    })
    .disposed(by: disposeBag)
```

### Notifications

Instead of using:

```swift
@available(iOS 4.0, *)
public func addObserverForName(name: String?, object obj: AnyObject?, queue: NSOperationQueue?, usingBlock block: (NSNotification) -> Void) -> NSObjectProtocol
```

... just write

```swift
NotificationCenter.default
    .rx.notification(NSNotification.Name.UITextViewTextDidBeginEditing, object: myTextView)
    .map {  /*do something with data*/ }
    ....
```

### Transient state

There are also a lot of problems with transient state when writing async programs. A typical example is an autocomplete search box.

If you were to write the autocomplete code without Rx, the first problem that probably needs to be solved is when `c` in `abc` is typed, and there is a pending request for `ab`, the pending request gets canceled. OK, that shouldn't be too hard to solve, you just create an additional variable to hold reference to the pending request.

The next problem is if the request fails, you need to do that messy retry logic. But OK, a couple more fields that capture the number of retries that need to be cleaned up.

It would be great if the program would wait for some time before firing a request to the server. After all, we don't want to spam our servers in case somebody is in the process of typing something very long. An additional timer field maybe?

There is also a question of what needs to be shown on screen while that search is executing, and also what needs to be shown in case we fail even with all of the retries.

Writing all of this and properly testing it would be tedious. This is that same logic written with Rx.

```swift
searchTextField.rx.text
    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
    .distinctUntilChanged()
    .flatMapLatest { query in
        API.getSearchResults(query)
            .retry(3)
            .startWith([]) // clears results on new search term
            .catchErrorJustReturn([])
    }
    .subscribe(onNext: { results in
      // bind to ui
    })
    .disposed(by: disposeBag)
```

There are no additional flags or fields required. Rx takes care of all that transient mess.

### Compositional disposal

Let's assume that there is a scenario where you want to display blurred images in a table view. First, the images should be fetched from a URL, then decoded and then blurred.

It would also be nice if that entire process could be canceled if a cell exits the visible table view area since bandwidth and processor time for blurring are expensive.

It would also be nice if we didn't just immediately start to fetch an image once the cell enters the visible area since, if user swipes really fast, there could be a lot of requests fired and canceled.

It would be also nice if we could limit the number of concurrent image operations because, again, blurring images is an expensive operation.

This is how we can do it using Rx:

```swift
// this is a conceptual solution
let imageSubscription = imageURLs
    .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
    .flatMapLatest { imageURL in
        API.fetchImage(imageURL)
    }
    .observeOn(operationScheduler)
    .map { imageData in
        return decodeAndBlurImage(imageData)
    }
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { blurredImage in
        imageView.image = blurredImage
    })
    .disposed(by: reuseDisposeBag)
```

This code will do all that and, when `imageSubscription` is disposed, it will cancel all dependent async operations and make sure no rogue image is bound to the UI.

### Aggregating network requests

What if you need to fire two requests and aggregate results when they have both finished?

Well, there is of course the `zip` operator

```swift
let userRequest: Observable<User> = API.getUser("me")
let friendsRequest: Observable<[Friend]> = API.getFriends("me")

Observable.zip(userRequest, friendsRequest) { user, friends in
    return (user, friends)
}
.subscribe(onNext: { user, friends in
    // bind them to the user interface
})
.disposed(by: disposeBag)
```

So what if those APIs return results on a background thread, and binding has to happen on the main UI thread? There is `observeOn`.

```swift
let userRequest: Observable<User> = API.getUser("me")
let friendsRequest: Observable<[Friend]> = API.getFriends("me")

Observable.zip(userRequest, friendsRequest) { user, friends in
    return (user, friends)
}
.observeOn(MainScheduler.instance)
.subscribe(onNext: { user, friends in
    // bind them to the user interface
})
.disposed(by: disposeBag)
```

There are many more practical use cases where Rx really shines.

### State

Languages that allow mutation make it easy to access global state and mutate it. Uncontrolled mutations of shared global state can easily cause [combinatorial explosion](https://en.wikipedia.org/wiki/Combinatorial_explosion#Computing).

But on the other hand, when used in a smart way, imperative languages can enable writing more efficient code closer to hardware.

The usual way to battle combinatorial explosion is to keep state as simple as possible, and use [unidirectional data flows](https://developer.apple.com/videos/play/wwdc2014-229) to model derived data.

This is where Rx really shines.

Rx is that sweet spot between functional and imperative worlds. It enables you to use immutable definitions and pure functions to process snapshots of mutable state in a reliable composable way.

So what are some practical examples?

### Easy integration

What if you need to create your own observable? It's pretty easy. This code is taken from RxCocoa and that's all you need to wrap HTTP requests with `URLSession`

```swift
extension Reactive where Base: URLSession {
    public func response(request: URLRequest) -> Observable<(Data, HTTPURLResponse)> {
        return Observable.create { observer in
            let task = self.base.dataTask(with: request) { (data, response, error) in
            
                guard let response = response, let data = data else {
                    observer.on(.error(error ?? RxCocoaURLError.unknown))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.on(.error(RxCocoaURLError.nonHTTPResponse(response: response)))
                    return
                }

                observer.on(.next(data, httpResponse))
                observer.on(.completed)
            }

            task.resume()

            return Disposables.create(with: task.cancel)
        }
    }
}
```

### Benefits

In short, using Rx will make your code:

* Composable <- Because Rx is composition's nickname
* Reusable <- Because it's composable
* Declarative <- Because definitions are immutable and only data changes
* Understandable and concise <- Raising the level of abstraction and removing transient states
* Stable <- Because Rx code is thoroughly unit tested
* Less stateful <- Because you are modeling applications as unidirectional data flows
* Without leaks <- Because resource management is easy

### It's not all or nothing

It is usually a good idea to model as much of your application as possible using Rx.

But what if you don't know all of the operators and whether or not there even exists some operator that models your particular case?

Well, all of the Rx operators are based on math and should be intuitive.

The good news is that about 10-15 operators cover most typical use cases. And that list already includes some of the familiar ones like `map`, `filter`, `zip`, `observeOn`, ...

There is a huge list of [all Rx operators](http://reactivex.io/documentation/operators.html).

For each operator, there is a [marble diagram](http://reactivex.io/documentation/operators/retry.html) that helps to explain how it works.

But what if you need some operator that isn't on that list? Well, you can make your own operator.

What if creating that kind of operator is really hard for some reason, or you have some legacy stateful piece of code that you need to work with? Well, you've got yourself in a mess, but you can [jump out of Rx monads](GettingStarted.md#life-happens) easily, process the data, and return back into it.
