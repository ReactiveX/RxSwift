import Cocoa
import RxSwift

/*:
# To use playgrounds please open `Rx.xcworkspace`, build `RxSwift-OSX` scheme and then open playgrounds in `Rx.xcworkspace` tree view.
*/
/*:
## Error Handling Operators

Operators that help to recover from error notifications from an Observable.
*/

/*:
### `catch`

Recover from an onError notification by continuing the sequence without error
[More info in reactive.io website]( http://reactivex.io/documentation/operators/catch.html )
*/

example("catch 1st") {
    
    let observable1 = PublishSubject<Int>()
    let observable2 = PublishSubject<Int>()
    
    observable1
        >- catch { error in
            return observable2
        }
        >- subscribe { event in
            switch event {
            case .Next(let box):
                println("\(box.value)")
            case .Completed:
                println("completed")
            case .Error(let error):
                println("\(error)")
            }
    }
    
    
    sendNext(observable1, 1)
    sendNext(observable1, 2)
    sendNext(observable1, 3)
    sendNext(observable1, 4)
    sendError(observable1, NSError(domain: "Test", code: 0, userInfo: nil))
    
    sendNext(observable2, 100)
    sendNext(observable2, 200)
    sendNext(observable2, 300)
    sendNext(observable2, 400)
    sendCompleted(observable2)
    
    
}

example("catch 2nd") {
    
    let observable1 = PublishSubject<Int>()
    
    observable1
        >- catch(100)
        >- subscribe { event in
            switch event {
            case .Next(let box):
                println("\(box.value)")
            case .Completed:
                println("completed")
            case .Error(let error):
                println("\(error)")
            }
    }
    
    
    sendNext(observable1, 1)
    sendNext(observable1, 2)
    sendNext(observable1, 3)
    sendNext(observable1, 4)
    sendError(observable1, NSError(domain: "Test", code: 0, userInfo: nil))
    
    
}


/*:
### `retry`

If a source Observable emits an error, resubscribe to it in the hopes that it will complete without error
[More info in reactive.io website]( http://reactivex.io/documentation/operators/retry.html )
*/

example("retry") {
    
    var count = 1 // bad practice, only for example purposes
    let observable: Observable<Int> = create { observer in
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        sendNext(observer, 0)
        sendNext(observer, 1)
        sendNext(observer, 2)
        if count < 2 {
            sendError(observer, error)
            count++
        }
        sendNext(observer, 3)
        sendNext(observer, 4)
        sendNext(observer, 5)
        sendCompleted(observer)
        
        return AnonymousDisposable {}
    }
    
    observable
        >- retry
        >- subscribe { event in
            switch event {
            case .Next(let box):
                println("\(box.value)")
            case .Completed:
                println("completed")
            case .Error(let error):
                println("\(error)")
            }
    }
}
