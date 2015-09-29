//
//  GitHubSearchRepositoriesViewController.swift
//  RxExample
//
//  Created by yoshinori_sano on 9/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

struct Repository: CustomStringConvertible {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    var description: String {
        return name
    }
}

class GitHubSearchRepositoriesAPI {
    
    static let sharedAPI = GitHubSearchRepositoriesAPI()
    
    private init() {}
    
    func search() -> Observable<[Repository]> {
        let url = NSURL(string: "https://api.github.com/search/repositories?q=othello")!
        return NSURLSession.sharedSession().rx_JSON(url)
            .observeOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            .map { json in
                guard let json = json as? [String: AnyObject] else {
                    throw exampleError("Casting to dictionary failed")
                }
                return try self.parseJSON(json)
            }
            .observeOn(Dependencies.sharedDependencies.mainScheduler)
    }
    
    private func parseJSON(json: [String: AnyObject]) throws -> [Repository] {
        guard let items = json["items"] as? [[String: AnyObject]] else {
            throw exampleError("Can't find results")
        }
        return try items.map { item in
            guard let name = item["name"] as? String else {
                throw exampleError("Can't parse repository")
            }
            return Repository(name: name)
        }
    }
}

class GitHubSearchRepositoriesViewController: ViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    let repositories = Variable([Repository]())
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let allRepositories = repositories
            .map { repositories in
                return [SectionModel(model: "Repositories", items: repositories)]
            }

        dataSource.cellFactory = { (tv, ip, repository: Repository) in
            let cell = tv.dequeueReusableCellWithIdentifier("Cell")!
            cell.textLabel?.text = repository.name
            return cell
        }

        dataSource.titleForHeaderInSection = { [unowned dataSource] sectionIndex in
            return dataSource.sectionAtIndex(sectionIndex).model
        }

        // reactive data source
        allRepositories
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)

        GitHubSearchRepositoriesAPI.sharedAPI.search()
            .subscribeNext { [unowned self] array in
                self.repositories.value = array
            }
            .addDisposableTo(disposeBag)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.editing = editing
    }
    
    // MARK: Table view delegate
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = dataSource.sectionAtIndex(section)
        
        let label = UILabel(frame: CGRect.zero)
        label.text = "  \(title)"
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.darkGrayColor()
        label.alpha = 0.9
        
        return label
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
