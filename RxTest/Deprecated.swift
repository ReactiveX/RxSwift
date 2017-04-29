//
//  Deprecated.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

extension TestScheduler {
    @available(*, deprecated, renamed: "start(disposed:create:)")
    public func start<Element>(_ disposed: TestTime, create: @escaping () -> Observable<Element>) -> TestableObserver<Element> {
        return start(Defaults.created, subscribed: Defaults.subscribed, disposed: disposed, create: create)
    }

    @available(*, deprecated, renamed: "start(created:subscribed:disposed:create:)")
    public func start<Element>(_ created: TestTime, subscribed: TestTime, disposed: TestTime, create: @escaping () -> Observable<Element>) -> TestableObserver<Element> {
        return start(created: created, subscribed: subscribed, disposed: disposed, create: create)
    }
}
