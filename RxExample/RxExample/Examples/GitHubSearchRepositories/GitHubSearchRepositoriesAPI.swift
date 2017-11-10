//
//  GitHubSearchRepositoriesAPI.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 10/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.URLRequest
import struct Foundation.NSRange
import class Foundation.HTTPURLResponse
import class Foundation.URLSession
import class Foundation.NSRegularExpression
import class Foundation.JSONSerialization
import class Foundation.NSString

/**
 Parsed GitHub repository.
*/
struct Repository: CustomDebugStringConvertible {
    var name: String
    var url: URL

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

extension Repository {
    var debugDescription: String {
        return "\(name) | \(url)"
    }
}

enum GitHubServiceError: Error {
    case offline
    case githubLimitReached
    case networkError
}

typealias SearchRepositoriesResponse = Result<(repositories: [Repository], nextURL: URL?), GitHubServiceError>

class GitHubSearchRepositoriesAPI {

    // *****************************************************************************************
    // !!! This is defined for simplicity sake, using singletons isn't advised               !!!
    // !!! This is just a simple way to move services to one location so you can see Rx code !!!
    // *****************************************************************************************
    static let sharedAPI = GitHubSearchRepositoriesAPI(reachabilityService: try! DefaultReachabilityService())

    fileprivate let _reachabilityService: ReachabilityService

    private init(reachabilityService: ReachabilityService) {
        _reachabilityService = reachabilityService
    }
}

extension GitHubSearchRepositoriesAPI {
    public func loadSearchURL(_ searchURL: URL) -> Observable<SearchRepositoriesResponse> {
        return URLSession.shared
            .rx.response(request: URLRequest(url: searchURL))
            .retry(3)
            .observeOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            .map { pair -> SearchRepositoriesResponse in
                if pair.0.statusCode == 403 {
                    return .failure(.githubLimitReached)
                }

                let jsonRoot = try GitHubSearchRepositoriesAPI.parseJSON(pair.0, data: pair.1)

                guard let json = jsonRoot as? [String: AnyObject] else {
                    throw exampleError("Casting to dictionary failed")
                }

                let repositories = try Repository.parse(json)

                let nextURL = try GitHubSearchRepositoriesAPI.parseNextURL(pair.0)

                return .success((repositories: repositories, nextURL: nextURL))
            }
            .retryOnBecomesReachable(.failure(.offline), reachabilityService: _reachabilityService)
    }
}

// MARK: Parsing the response

extension GitHubSearchRepositoriesAPI {

    private static let parseLinksPattern = "\\s*,?\\s*<([^\\>]*)>\\s*;\\s*rel=\"([^\"]*)\""
    private static let linksRegex = try! NSRegularExpression(pattern: parseLinksPattern, options: [.allowCommentsAndWhitespace])

    fileprivate static func parseLinks(_ links: String) throws -> [String: String] {

        let length = (links as NSString).length
        let matches = GitHubSearchRepositoriesAPI.linksRegex.matches(in: links, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: length))

        var result: [String: String] = [:]

        for m in matches {
            let matches = (1 ..< m.numberOfRanges).map { rangeIndex -> String in
                let range = m.range(at: rangeIndex)
                let startIndex = links.index(links.startIndex, offsetBy: range.location)
                let endIndex = links.index(links.startIndex, offsetBy: range.location + range.length)
                return String(links[startIndex ..< endIndex])
            }

            if matches.count != 2 {
                throw exampleError("Error parsing links")
            }

            result[matches[1]] = matches[0]
        }
        
        return result
    }

    fileprivate static func parseNextURL(_ httpResponse: HTTPURLResponse) throws -> URL? {
        guard let serializedLinks = httpResponse.allHeaderFields["Link"] as? String else {
            return nil
        }

        let links = try GitHubSearchRepositoriesAPI.parseLinks(serializedLinks)

        guard let nextPageURL = links["next"] else {
            return nil
        }

        guard let nextUrl = URL(string: nextPageURL) else {
            throw exampleError("Error parsing next url `\(nextPageURL)`")
        }

        return nextUrl
    }

    fileprivate static func parseJSON(_ httpResponse: HTTPURLResponse, data: Data) throws -> AnyObject {
        if !(200 ..< 300 ~= httpResponse.statusCode) {
            throw exampleError("Call failed")
        }

        return try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
    }
    
}

extension Repository {
    fileprivate static func parse(_ json: [String: AnyObject]) throws -> [Repository] {
        guard let items = json["items"] as? [[String: AnyObject]] else {
            throw exampleError("Can't find items")
        }
        return try items.map { item in
            guard let name = item["name"] as? String,
                let url = item["url"] as? String else {
                throw exampleError("Can't parse repository")
            }
            return Repository(name: name, url: try URL(string: url).unwrap())
        }
    }
}
