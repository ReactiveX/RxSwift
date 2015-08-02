//
//  TableViewController.swift
//  RxExample
//
//  Created by carlos on 26/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class TableViewController: ViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    let users = Variable([User]())
    let favoriteUsers = Variable([User]())
    
    var allSections: [SectionModel<String, User>] = []
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>>()

    typealias Section = SectionModel<String, User>

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let allUsers = combineLatest(favoriteUsers, users) { favoriteUsers, users in
            return [
                SectionModel(model: "Favorite Users", items: favoriteUsers),
                SectionModel(model: "Normal Users", items: users)
            ]
        }
        
        // This is for demonstration purposes of UITableViewDelegate/DataSource
        // only, try to not do something like this in your app
        allUsers
            >- subscribeNext { [unowned self] n in
                self.allSections = n
            }
            >- disposeBag.addDisposable
        
        dataSource.cellFactory = { (tv, ip, user: User) in
            let cell = tv.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
            cell.textLabel?.text = user.firstName + " " + user.lastName
            return cell
        }
        
        dataSource.titleForHeaderInSection = { [unowned dataSource] sectionIndex in
            return dataSource.sectionAtIndex(sectionIndex).model
        }
        
        // reactive data source
        allUsers
            >- tableView.rx_subscribeWithReactiveDataSource(dataSource)
            >- disposeBag.addDisposable
        
        // customization using delegate
        // RxTableViewDelegateBridge will forward correct messages
        tableView.rx_setDelegate(self)
            >- disposeBag.addDisposable
        
        tableView.rx_itemSelected
            >- subscribeNext { [unowned self] indexPath in
                self.showDetailsForUserAtIndexPath(indexPath)
            }
            >- disposeBag.addDisposable
        
        tableView.rx_itemDeleted
            >- subscribeNext { [unowned self] indexPath in
                self.removeUser(indexPath)
            }
            >- disposeBag.addDisposable
        
        tableView.rx_itemMoved
            >- subscribeNext { [unowned self] (s, d) in
                self.moveUserFrom(s, to: d)
            }
            >- disposeBag.addDisposable
        
        // Rx content offset
        tableView.rx_contentOffset
            >- subscribeNext { co in
                println("Content offset from Rx observer \(co)")
            }
        
        RandomUserAPI.sharedAPI.getExampleUserResultSet()
            >- subscribeNext { [unowned self] array in
                self.users.next(array)
            }
            >- disposeBag.addDisposable
        
        favoriteUsers.next([User(firstName: "Super", lastName: "Man", imageURL: "http://nerdreactor.com/wp-content/uploads/2015/02/Superman1.jpg")])
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.editing = editing
    }
    
    // MARK: Table view delegate ;)
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = dataSource.sectionAtIndex(section)
        
        let label = UILabel(frame: CGRect.zeroRect)
        // hacky I know :)
        label.text = "  \(title)"
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.darkGrayColor()
        label.alpha = 0.9
        
        return label
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        println("Content offset from delegate \(scrollView.contentOffset)")
    }
    
    // MARK: Navigation
    
    private func showDetailsForUserAtIndexPath(indexPath: NSIndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: NSBundle(identifier: "RxExample-iOS"))
        let vc = sb.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        vc.user = getUser(indexPath)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Work over Variable
    
    func getUser(indexPath: NSIndexPath) -> User {
        var array: [User]
        switch indexPath.section {
        case 0:
            array = favoriteUsers.value
        case 1:
            array = users.value
        default:
            fatalError("Section out of range")
        }
        return array[indexPath.row]
    }
    
    func moveUserFrom(from: NSIndexPath, to: NSIndexPath) {
        var user: User
        var fromArray: [User]
        var toArray: [User]
        
        switch from.section {
        case 0:
            fromArray = favoriteUsers.value
            user = fromArray.removeAtIndex(from.row)
            favoriteUsers.next(fromArray)
        case 1:
            fromArray = users.value
            user = fromArray.removeAtIndex(from.row)
            users.next(fromArray)
        default:
            fatalError("Section out of range")
        }
        
        
        switch to.section {
        case 0:
            toArray = favoriteUsers.value
            toArray.insert(user, atIndex: to.row)
            favoriteUsers.next(toArray)
        case 1:
            toArray = users.value
            toArray.insert(user, atIndex: to.row)
            users.next(toArray)
        default:
            fatalError("Section out of range")
        }
    }
    
    func addUser(user: User) {
        var array = users.value
        array.append(user)
        users.next(array)
    }
    
    func removeUser(indexPath: NSIndexPath) {
        var array: [User]
        switch indexPath.section {
        case 0:
            array = favoriteUsers.value
            array.removeAtIndex(indexPath.row)
            favoriteUsers.next(array)
        case 1:
            array = users.value
            array.removeAtIndex(indexPath.row)
            users.next(array)
        default:
            fatalError("Section out of range")
        }
    }
    
}
