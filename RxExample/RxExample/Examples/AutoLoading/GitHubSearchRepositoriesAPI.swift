//
//  GitHubSearchRepositoriesAPI.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 10/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

struct Repository: CustomStringConvertible {
    var name: String
    var url: String

    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
    
    var description: String {
        return "\(name) | \(url)"
    }
}

enum SearchRepositoryResponse {
    case Repositories([Repository])
    case LimitExceeded
}


class GitHubSearchRepositoriesAPI {

    static let sharedAPI = GitHubSearchRepositoriesAPI()

    let activityIndicator = ActivityIndicator()

    private init() {
    }

    private static let parseLinksPattern = "\\s*,?\\s*<([^\\>]*)>\\s*;\\s*rel=\"([^\"]*)\""
    private static let linksRegex = try! NSRegularExpression(pattern: parseLinksPattern, options: [.AllowCommentsAndWhitespace])

    private static func parseLinks(links: String) throws -> [String: String] {

        let length = (links as NSString).length
        let matches = GitHubSearchRepositoriesAPI.linksRegex.matchesInString(links, options: NSMatchingOptions(), range: NSRange(location: 0, length: length))

        var result: [String: String] = [:]

        for m in matches {
            let matches = (1 ..< m.numberOfRanges).map { rangeIndex -> String in
                let range = m.rangeAtIndex(rangeIndex)
                let startIndex = links.startIndex.advancedBy(range.location)
                let endIndex = startIndex.advancedBy(range.length)
                let stringRange = Range(start: startIndex, end: endIndex)
                return links.substringWithRange(stringRange)
            }

            if matches.count != 2 {
                throw exampleError("Error parsing links")
            }

            result[matches[1]] = matches[0]
        }
        
        return result
    }

    private static func parseNextURL(httpResponse: NSHTTPURLResponse) throws -> NSURL? {
        guard let serializedLinks = httpResponse.allHeaderFields["Link"] as? String else {
            return nil
        }

        let links = try GitHubSearchRepositoriesAPI.parseLinks(serializedLinks)

        guard let nextPageURL = links["next"] else {
            return nil
        }

        guard let nextUrl = NSURL(string: nextPageURL) else {
            throw exampleError("Error parsing next url `\(nextPageURL)`")
        }

        return nextUrl
    }

    /**
    Public fascade for search.
    */
    func search(query: String, loadNextPageTrigger: Observable<Void>) -> Observable<SearchRepositoryResponse> {
        let escapedQuery = URLEscape(query)
        let url = NSURL(string: "https://api.github.com/search/repositories?q=\(escapedQuery)")!
        return recursivelySearch([], loadNextURL: url, loadNextPageTrigger: loadNextPageTrigger)
            .startWith(.Repositories([]))
    }

    private func recursivelySearch(loadedSoFar: [Repository], loadNextURL: NSURL, loadNextPageTrigger: Observable<Void>) -> Observable<SearchRepositoryResponse> {
        return loadSearchURL(loadNextURL)
            .retry(3)
            .flatMap { (newPageRepositoriesResponse, nextURL) -> Observable<SearchRepositoryResponse> in
                // in case access denied, just stop
                guard case .Repositories(let newPageRepositories) = newPageRepositoriesResponse else {
                    return just(newPageRepositoriesResponse)
                }

                var loadedRepositories = loadedSoFar
                loadedRepositories.appendContentsOf(newPageRepositories)

                // if next page can't be loaded, just return what was loaded, and stop
                guard let nextURL = nextURL else {
                    return just(.Repositories(loadedRepositories))
                }

                return [
                    // return loaded immediately
                    just(.Repositories(loadedRepositories)),
                    // wait until next page can be loaded
                    never().takeUntil(loadNextPageTrigger),
                    // load next page
                    self.recursivelySearch(loadedRepositories, loadNextURL: nextURL, loadNextPageTrigger: loadNextPageTrigger)
                ].concat()
            }
    }

    private func loadSearchURL(searchURL: NSURL) -> Observable<(response: SearchRepositoryResponse, nextURL: NSURL?)> {
        return NSURLSession.sharedSession()
            .rx_response(NSURLRequest(URL: searchURL))
            .trackActivity(self.activityIndicator)
            .observeOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            .map { data, response in
                guard let httpResponse = response as? NSHTTPURLResponse else {
                    throw exampleError("not getting http response")
                }

                if httpResponse.statusCode == 403 {
                    return (response: .LimitExceeded, nextURL: nil)
                }

                let jsonRoot = try GitHubSearchRepositoriesAPI.parseJSON(httpResponse, data: data)

                guard let json = jsonRoot as? [String: AnyObject] else {
                    throw exampleError("Casting to dictionary failed")
                }

                let repositories = try GitHubSearchRepositoriesAPI.parseRepositories(json)

                let nextURL = try GitHubSearchRepositoriesAPI.parseNextURL(httpResponse)

                return (response: .Repositories(repositories), nextURL: nextURL)
            }
            .observeOn(Dependencies.sharedDependencies.mainScheduler)
    }

    private static func parseJSON(httpResponse: NSHTTPURLResponse, data: NSData) throws -> AnyObject {
        if !(200 ..< 300 ~= httpResponse.statusCode) {
            throw exampleError("Call failed")
        }

        return try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: [])
    }
    
    private static func parseRepositories(json: [String: AnyObject]) throws -> [Repository] {
        guard let items = json["items"] as? [[String: AnyObject]] else {
            throw exampleError("Can't find items")
        }
        return try items.map { item in
            guard let name = item["name"] as? String,
                    url = item["url"] as? String else {
                throw exampleError("Can't parse repository")
            }
            return Repository(name: name, url: url)
        }
    }
}
