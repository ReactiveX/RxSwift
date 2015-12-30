# Migration from RxSwift 1.9 to RxSwift 2.0 version

The migration should be pretty straightforward. The changes are mostly cosmetic, so all features are still there.

* Find replace all `>- ` to `.`
* Find replace all "variable" to "shareReplay(1)"
* Find replace all "catch" to "catchErrorJustReturn"
* Find replace all "returnElement" to "Observable.just"
* Find replace all "failWith" to "Observable.error"
* Find replace all "never" to "Observable.never"
* Find replace all "empty" to "Observable.empty"
* Since we've moved from `>-` to `.`, free functions are now methods, so it's `.switchLatest()`, `.distinctUntilChanged()`, ... instead of `>- switchLatest`, `>- distinctUntilChanged`
* we've moved from free functions to extensions so it's now `[a, b, c].concat()`, `.merge()`, ... instead of `concat([a, b, c])`, `merge(sequences)`
* Now it's `subscribe { n in ... }.addDisposableTo(disposeBag)` instead of `>- disposeBag.addDisposable`
* Method `next` on `Variable` is now `value` setter
* If you want to use `tableViews`/`collectionViews`, this is the basic use case now

```swift
viewModel.rows
            .bindTo(resultsTableView.rx_itemsWithCellIdentifier("WikipediaSearchCell", cellType: WikipediaSearchCell.self)) { (_, viewModel, cell) in
                cell.viewModel = viewModel
            }
            .addDisposableTo(disposeBag)
```

If you have any more doubts how to write some concept in RxSwift 2.0 version, check out [Example app](../RxExample) or playgrounds.
