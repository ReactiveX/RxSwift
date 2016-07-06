//
//  TableViewWithEditingCommandsViewController.swift
//  RxExample
//
//  Created by carlos on 26/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

/**
Another way to do "MVVM". There are different ideas what does MVVM mean depending on your background.
 It's kind of similar like FRP.
 
 In the end, it doesn't really matter what jargon are you using.
 
 This would be the ideal case, but it's really hard to model complex views this way
 because it's not possible to observe partial model changes.
*/
struct TableViewEditingCommandsViewModel {
    let favoriteUsers: [User]
    let users: [User]

    func executeCommand(_ command: TableViewEditingCommand) -> TableViewEditingCommandsViewModel {
        switch command {
        case let .setUsers(users):
            return TableViewEditingCommandsViewModel(favoriteUsers: favoriteUsers, users: users)
        case let .setFavoriteUsers(favoriteUsers):
            return TableViewEditingCommandsViewModel(favoriteUsers: favoriteUsers, users: users)
        case let .deleteUser(indexPath):
            var all = [self.favoriteUsers, self.users]
            all[(indexPath as NSIndexPath).section].remove(at: (indexPath as NSIndexPath).row)
            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
        case let .moveUser(from, to):
            var all = [self.favoriteUsers, self.users]
            let user = all[(from as NSIndexPath).section][(from as NSIndexPath).row]
            all[(from as NSIndexPath).section].remove(at: (from as NSIndexPath).row)
            all[(to as NSIndexPath).section].insert(user, at: (to as NSIndexPath).row)

            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
        }
    }
}

enum TableViewEditingCommand {
    case setUsers(users: [User])
    case setFavoriteUsers(favoriteUsers: [User])
    case deleteUser(indexPath: IndexPath)
    case moveUser(from: IndexPath, to: IndexPath)
}

class TableViewWithEditingCommandsViewController: ViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    let dataSource = TableViewWithEditingCommandsViewController.configureDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem()

        let superMan =  User(
            firstName: "Super",
            lastName: "Man",
            imageURL: "http://nerdreactor.com/wp-content/uploads/2015/02/Superman1.jpg"
        )

        let watMan = User(firstName: "Wat",
            lastName: "Man",
            imageURL: "http://www.iri.upc.edu/files/project/98/main.GIF"
        )

        let loadFavoriteUsers = RandomUserAPI.sharedAPI
                .getExampleUserResultSet()
                .map(TableViewEditingCommand.setUsers)

        let initialLoadCommand = Observable.just(TableViewEditingCommand.setFavoriteUsers(favoriteUsers: [superMan, watMan]))
                .concat(loadFavoriteUsers)
                .observeOn(MainScheduler.instance)

        let deleteUserCommand = tableView.rx_itemDeleted.map(TableViewEditingCommand.deleteUser)
        let moveUserCommand = tableView
            .rx_itemMoved
            // This is needed because rx_itemMoved is being performed before delegate method is
            // delegated to RxDataSource.
            // This observeOn makes sure data is rebound after automatic move is performed in data source.
            // This will be improved in RxSwift 3.0 when order will be inversed.
            .observeOn(MainScheduler.asyncInstance)
            .map(TableViewEditingCommand.moveUser)

        let initialState = TableViewEditingCommandsViewModel(favoriteUsers: [], users: [])

        let viewModel =  Observable.of(initialLoadCommand, deleteUserCommand, moveUserCommand)
            .merge()
            .scan(initialState) { $0.executeCommand($1) }
            .shareReplay(1)

        viewModel
            .map {
                [
                    SectionModel(model: "Favorite Users", items: $0.favoriteUsers),
                    SectionModel(model: "Normal Users", items: $0.users)
                ]
            }
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)

        tableView.rx_itemSelected
            .withLatestFrom(viewModel) { i, viewModel in
                let all = [viewModel.favoriteUsers, viewModel.users]
                return all[i.section][i.row]
            }
            .subscribeNext { [weak self] user in
                self?.showDetailsForUser(user)
            }
            .addDisposableTo(disposeBag)

        // customization using delegate
        // RxTableViewDelegateBridge will forward correct messages
        tableView.rx_setDelegate(self)
            .addDisposableTo(disposeBag)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }

    // MARK: Table view delegate ;)

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = dataSource.sectionAtIndex(section)

        let label = UILabel(frame: CGRect.zero)
        // hacky I know :)
        label.text = "  \(title)"
        label.textColor = UIColor.white()
        label.backgroundColor = UIColor.darkGray()
        label.alpha = 0.9

        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // MARK: Navigation

    private func showDetailsForUser(_ user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(identifier: "RxExample-iOS"))
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.user = user
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: Work over Variable

    static func configureDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, User>> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>>()

        dataSource.configureCell = { (_, tv, ip, user: User) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = user.firstName + " " + user.lastName
            return cell
        }

        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            return dataSource.sectionAtIndex(sectionIndex).model
        }

        dataSource.canEditRowAtIndexPath = { (ds, ip) in
            return true
        }

        dataSource.canMoveRowAtIndexPath = { _ in
            return true
        }

        return dataSource
    }

}
