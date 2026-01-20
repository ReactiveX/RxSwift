//
//  SearchResultViewModel.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift

class SearchResultViewModel {
    let searchResult: WikipediaSearchResult

    var title: Driver<String>
    var imageURLs: Driver<[URL]>

    let API = DefaultWikipediaAPI.sharedAPI
    let `$`: Dependencies = .sharedDependencies

    init(searchResult: WikipediaSearchResult) {
        self.searchResult = searchResult

        title = Driver.never()
        imageURLs = Driver.never()

        let URLs = configureImageURLs()

        imageURLs = URLs.asDriver(onErrorJustReturn: [])
        title = configureTitle(URLs).asDriver(onErrorJustReturn: "Error during fetching")
    }

    // private methods

    func configureTitle(_ imageURLs: Observable<[URL]>) -> Observable<String> {
        let searchResult = searchResult

        let loadingValue: [URL]? = nil

        return imageURLs
            .map(Optional.init)
            .startWith(loadingValue)
            .map { URLs in
                if let URLs {
                    "\(searchResult.title) (\(URLs.count) pictures)"
                } else {
                    "\(searchResult.title) (loading…)"
                }
            }
            .retryOnBecomesReachable("⚠️ Service offline ⚠️", reachabilityService: `$`.reachabilityService)
    }

    func configureImageURLs() -> Observable<[URL]> {
        let searchResult = searchResult
        return API.articleContent(searchResult)
            .observe(on: `$`.backgroundWorkScheduler)
            .map { page in
                do {
                    return try parseImageURLsfromHTMLSuitableForDisplay(page.text as NSString)
                } catch {
                    return []
                }
            }
            .share(replay: 1)
    }
}
