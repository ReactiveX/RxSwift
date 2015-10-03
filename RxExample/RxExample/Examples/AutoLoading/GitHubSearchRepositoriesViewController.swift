//
//  GitHubSearchRepositoriesViewController.swift
//  RxExample
//
//  Created by Yoshinori Sano on 9/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
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

    private init() {}

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
        return loadSearchURL(loadNextURL).flatMap { (newPageRepositoriesResponse, nextURL) -> Observable<SearchRepositoryResponse> in
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

class GitHubSearchRepositoriesViewController: ViewController, UITableViewDelegate {
    static let startLoadingOffset: CGFloat = 20.0

    static func isNearTheBottomEdge(contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
    }

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var disposeBag = DisposeBag()
    let repositories = Variable([Repository]())
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let $: Dependencies = Dependencies.sharedDependencies

        let tableView = self.tableView
        let searchBar = self.searchBar

        let allRepositories = repositories
            .map { repositories in
                return [SectionModel(model: "Repositories", items: repositories)]
            }

        dataSource.cellFactory = { (tv, ip, repository: Repository) in
            let cell = tv.dequeueReusableCellWithIdentifier("Cell")!
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.url
            return cell
        }

        dataSource.titleForHeaderInSection = { [unowned dataSource] sectionIndex in
            let section = dataSource.sectionAtIndex(sectionIndex)
            return section.items.count > 0 ? "Repositories (\(section.items.count))" : "No repositories found"
        }

        // reactive data source
        allRepositories
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)

        let loadNextPageTrigger = tableView.rx_contentOffset
            .flatMap { offset in
                GitHubSearchRepositoriesViewController.isNearTheBottomEdge(offset, tableView)
                    ? just()
                    : empty()
            }

        searchBar.rx_text
            .throttle(0.3, $.mainScheduler)
            .distinctUntilChanged()
            .map { query -> Observable<SearchRepositoryResponse> in
                if query.isEmpty {
                    return just(.Repositories([]))
                } else {
                    return GitHubSearchRepositoriesAPI.sharedAPI.search(query, loadNextPageTrigger: loadNextPageTrigger)
                        .retry(3)
                        .catchErrorJustReturn(.Repositories([]))
                }
            }
            .switchLatest()
            .subscribeNext { [unowned self] result in
                switch result {
                case .Repositories(let repositories):
                    self.repositories.value = repositories
                case .LimitExceeded:
                    self.repositories.value = []
                    showAlert("Exceeded limit of 10 non authenticated requests per minute for GitHub API. Please wait a minute. :(\nhttps://developer.github.com/v3/#rate-limiting")
                }
            }
            .addDisposableTo(disposeBag)

        // dismiss keyboard on scroll
        tableView.rx_contentOffset
            .subscribe { _ in
                if searchBar.isFirstResponder() {
                    _ = searchBar.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)

        // so normal delegate customization can also be used
        tableView.rx_setDelegate(self)
            .addDisposableTo(disposeBag)
    }

    // MARK: Table view delegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
