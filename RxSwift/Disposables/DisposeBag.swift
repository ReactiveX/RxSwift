//
//  DisposeBag.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension Disposable {
    /// Adds `self` to `bag`
    ///
    /// - parameter bag: `DisposeBag` to add `self` to.
    func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
}

/**
 Thread safe bag that disposes added disposables on `deinit`.

 This returns ARC (RAII) like resource management to `RxSwift`.

 In case contained disposables need to be disposed, just put a different dispose bag
 or create a new one in its place.

     self.existingDisposeBag = DisposeBag()

 In case explicit disposal is necessary, there is also `CompositeDisposable`.
 */
public final class DisposeBag: DisposeBase {
    private var lock = SpinLock()

    // state
    private var disposables = [Disposable]()
    private var isDisposed = false

    /// Constructs new empty dispose bag.
    override public init() {
        super.init()
    }

    /// Adds `disposable` to be disposed when dispose bag is being deinited.
    ///
    /// - parameter disposable: Disposable to add.
    public func insert(_ disposable: Disposable) {
        _insert(disposable)?.dispose()
    }

    private func _insert(_ disposable: Disposable) -> Disposable? {
        lock.performLocked {
            if self.isDisposed {
                return disposable
            }

            self.disposables.append(disposable)

            return nil
        }
    }

    /// This is internal on purpose, take a look at `CompositeDisposable` instead.
    private func dispose() {
        let oldDisposables = _dispose()

        for disposable in oldDisposables {
            disposable.dispose()
        }
    }

    private func _dispose() -> [Disposable] {
        lock.performLocked {
            let disposables = self.disposables

            self.disposables.removeAll(keepingCapacity: false)
            self.isDisposed = true

            return disposables
        }
    }

    deinit {
        self.dispose()
    }
}

public extension DisposeBag {
    /// Convenience init allows a list of disposables to be gathered for disposal.
    convenience init(disposing disposables: Disposable...) {
        self.init()
        self.disposables += disposables
    }

    /// Convenience init which utilizes a function builder to let you pass in a list of
    /// disposables to make a DisposeBag of.
    convenience init(@DisposableBuilder builder: () -> [Disposable]) {
        self.init(disposing: builder())
    }

    /// Convenience init allows an array of disposables to be gathered for disposal.
    convenience init(disposing disposables: [Disposable]) {
        self.init()
        self.disposables += disposables
    }

    /// Convenience function allows a list of disposables to be gathered for disposal.
    func insert(_ disposables: Disposable...) {
        insert(disposables)
    }

    /// Convenience function allows a list of disposables to be gathered for disposal.
    func insert(@DisposableBuilder builder: () -> [Disposable]) {
        insert(builder())
    }

    /// Convenience function allows an array of disposables to be gathered for disposal.
    func insert(_ disposables: [Disposable]) {
        lock.performLocked {
            if self.isDisposed {
                disposables.forEach { $0.dispose() }
            } else {
                self.disposables += disposables
            }
        }
    }

    @resultBuilder
    struct DisposableBuilder {
        public static func buildBlock(_ disposables: Disposable...) -> [Disposable] {
            disposables
        }
    }
}
