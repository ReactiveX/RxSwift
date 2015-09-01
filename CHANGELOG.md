# Change Log
All notable changes to this project will be documented in this file.

---

## [2.0](https://github.com/ReactiveX/RxSwift/pull/50) (WIP)

#### Updated

* Removes deprecated APIs
* Adds `ObservableType`
* Moved from using `>-` operator to protocol extensions
* Change from `disposeBag.addDisposable` to `disposable.addDisposableTo`
* Changes in RxCocoa extensions to enable fluent style
* Rename of `do*` to `doOn*`
* Deprecates `aggregate` in favor of `reduce`
* Deprecates `variable` in favor of `shareReplay(1)` (to be consistent with RxJS version)


#### Fixed

## [1.9.1](https://github.com/ReactiveX/RxSwift/releases/tag/1.9.1)

#### Updated

* Adds Calculator example app
* Performance improvements for Queue

#### Fixed

* Crash in `rx_didChangeAuthorizationStatus`. [#89](https://github.com/ReactiveX/RxSwift/issues/89)
