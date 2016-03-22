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

/**
 Parsed GitHub respository.
*/
struct Repository: CustomDebugStringConvertible {
    var name: String
    var url: String

    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

extension Repository {
    var debugDescription: String {
        return "\(name) | \(url)"
    }
}

/**
ServiceState state.
*/
enum ServiceState {
    case Online
    case Offline
}

/**
 Raw response from GitHub API
*/
enum SearchRepositoryResponse {
    /**
     New repositories just fetched
    */
    case Repositories(repositories: [Repository], nextURL: NSURL?)

    /**
     In case there was some problem fetching data from service, this will be returned.
     It really doesn't matter if that is a failure in network layer, parsing error or something else.
     In case data can't be read and parsed properly, something is wrong with server response.
    */
    case ServiceOffline

    /**
     This example uses unauthenticated GitHub API. That API does have throttling policy and you won't
     be able to make more then 10 requests per minute.
     
     That is actually an awesome scenario to demonstrate complex retries using alert views and combination of timers.
     
     Just search like mad, and everything will be handled right.
    */
    case LimitExceeded
}

/**
 This is the final result of loading. Crème de la crème.
*/
struct RepositoriesState {
    /**
     List of parsed repositories ready to be shown in the UI.
    */
    let repositories: [Repository]

    /**
     Current network state.
    */
    let serviceState: ServiceState?

    /**
     Limit exceeded
    */
    let limitExceeded: Bool

    static let empty = RepositoriesState(repositories: [], serviceState: nil, limitExceeded: false)
}


class GitHubSearchRepositoriesAPI {

    static let sharedAPI = GitHubSearchRepositoriesAPI(wireframe: DefaultWireframe())

    let activityIndicator = ActivityIndicator()

    // Why would network service have wireframe service? It's here to abstract promting user
    // Do we really want to make this example project factory/fascade/service competition? :)
    private let _wireframe: Wireframe

    private init(wireframe: Wireframe) {
        _wireframe = wireframe
    }

}

// MARK: Pagination

extension GitHubSearchRepositoriesAPI {
    /**
    Public fascade for search.
    */
    func search(query: String, loadNextPageTrigger: Observable<Void>) -> Observable<RepositoriesState> {
        let escapedQuery = query.URLEscaped
        let url = NSURL(string: "https://api.github.com/search/repositories?q=\(escapedQuery)")!
        return recursivelySearch([], loadNextURL: url, loadNextPageTrigger: loadNextPageTrigger)
            // Here we go again
            .startWith(RepositoriesState.empty)
    }

    private func recursivelySearch(loadedSoFar: [Repository], loadNextURL: NSURL, loadNextPageTrigger: Observable<Void>) -> Observable<RepositoriesState> {
        return loadSearchURL(loadNextURL).flatMap { searchResponse -> Observable<RepositoriesState> in
            switch searchResponse {
            /**
                If service is offline, that's ok, that means that this isn't the last thing we've heard from that API.
                It will retry until either battery drains, you become angry and close the app or evil machine comes back
                from the future, steals your device and Googles Sarah Connor's address.
            */
            case .ServiceOffline:
                return Observable.just(RepositoriesState(repositories: loadedSoFar, serviceState: .Offline, limitExceeded: false))
                
            case .LimitExceeded:
                return Observable.just(RepositoriesState(repositories: loadedSoFar, serviceState: .Online, limitExceeded: true))

            case let .Repositories(newPageRepositories, maybeNextURL):

                var loadedRepositories = loadedSoFar
                loadedRepositories.appendContentsOf(newPageRepositories)

                let appenedRepositories = RepositoriesState(repositories: loadedRepositories, serviceState: .Online, limitExceeded: false)

                // if next page can't be loaded, just return what was loaded, and stop
                guard let nextURL = maybeNextURL else {
                    return Observable.just(appenedRepositories)
                }

                return [
                    // return loaded immediately
                    Observable.just(appenedRepositories),
                    // wait until next page can be loaded
                    Observable.never().takeUntil(loadNextPageTrigger),
                    // load next page
                    self.recursivelySearch(loadedRepositories, loadNextURL: nextURL, loadNextPageTrigger: loadNextPageTrigger)
                ].concat()
            }
        }
    }

    private func loadSearchURL(searchURL: NSURL) -> Observable<SearchRepositoryResponse> {
        return NSURLSession.sharedSession()
            .rx_response(NSURLRequest(URL: searchURL))
            .retry(3)
            .trackActivity(self.activityIndicator)
            .observeOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            .map { data, httpResponse -> SearchRepositoryResponse in
                if httpResponse.statusCode == 403 {
                    return .LimitExceeded
                }

                let jsonRoot = try GitHubSearchRepositoriesAPI.parseJSON(httpResponse, data: data)

                guard let json = jsonRoot as? [String: AnyObject] else {
                    throw exampleError("Casting to dictionary failed")
                }

                let repositories = try GitHubSearchRepositoriesAPI.parseRepositories(json)

                let nextURL = try GitHubSearchRepositoriesAPI.parseNextURL(httpResponse)

                return .Repositories(repositories: repositories, nextURL: nextURL)
            }
            .retryOnBecomesReachable(.ServiceOffline, reachabilityService: ReachabilityService.sharedReachabilityService)
    }
}

// MARK: Parsing the response

extension GitHubSearchRepositoriesAPI {

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
                let stringRange = startIndex ..< endIndex
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
