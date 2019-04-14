//
//  ExampleTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/11/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift

final class ExampleTests: RxTest {}

struct Repository {

}

extension ExampleTests {
    func testWelcomePage() {
        _ = autoreleasepool { () -> Observable<[Repository]> in

            let searchBar = UISearchBar()
            func searchGitHub(_ query: String) -> Observable<[Repository]> {
                return Observable.empty()
            }

            let searchResults = searchBar.rx.text.orEmpty
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .flatMapLatest { query -> Observable<[Repository]> in
                    if query.isEmpty {
                        return .just([])
                    }
                    return searchGitHub(query)
                        .catchErrorJustReturn([])
                }
                .observeOn(MainScheduler.instance)


            return searchResults
        }
    }
}
