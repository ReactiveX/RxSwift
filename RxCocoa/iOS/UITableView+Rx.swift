//
//  UITableView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

// Items

extension Reactive where Base: UITableView {
    
    /**
    Binds sequences of elements to table view rows.
    
    - parameter source: Observable sequence of items.
    - parameter cellFactory: Transform between sequence elements and view cells.
    - returns: Disposable object that can be used to unbind.
     
     Example:
    
         let items = Observable.just([
             "First Item",
             "Second Item",
             "Third Item"
         ])

         items
         .bindTo(tableView.rx.itemsWithCellFactory) { (tableView, row, element) in
             let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
             cell.textLabel?.text = "\(element) @ row \(row)"
             return cell
         }
         .addDisposableTo(disposeBag)

    */
    @available(*, deprecated, renamed: "items(source:cellFactory:)")
    public func itemsWithCellFactory<S: Sequence, O: ObservableType where O.E == S>
        (_ source: O)
        -> (cellFactory: (UITableView, Int, S.Iterator.Element) -> UITableViewCell)
        -> Disposable {
        return { cellFactory in
            let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S>(cellFactory: cellFactory)
            
            return self.items(dataSource: dataSource)(source: source)
        }
    }

    /**
    Binds sequences of elements to table view rows.
    
    - parameter source: Observable sequence of items.
    - parameter cellFactory: Transform between sequence elements and view cells.
    - returns: Disposable object that can be used to unbind.
     
     Example:
    
         let items = Observable.just([
             "First Item",
             "Second Item",
             "Third Item"
         ])

         items
         .bindTo(tableView.items) { (tableView, row, element) in
             let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
             cell.textLabel?.text = "\(element) @ row \(row)"
             return cell
         }
         .addDisposableTo(disposeBag)

     */
    public func items<S: Sequence, O: ObservableType where O.E == S>
        (_ source: O)
        -> (cellFactory: (UITableView, Int, S.Iterator.Element) -> UITableViewCell)
        -> Disposable {
            return { cellFactory in
                let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S>(cellFactory: cellFactory)

                return self.items(dataSource: dataSource)(source: source)
            }
    }

    /**
    Binds sequences of elements to table view rows.
    
    - parameter cellIdentifier: Identifier used to dequeue cells.
    - parameter source: Observable sequence of items.
    - parameter configureCell: Transform between sequence elements and view cells.
    - parameter cellType: Type of table view cell.
    - returns: Disposable object that can be used to unbind.
     
     Example:

         let items = Observable.just([
             "First Item",
             "Second Item",
             "Third Item"
         ])

         items
             .bindTo(tableView.rx.itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
             }
             .addDisposableTo(disposeBag)
    */
    @available(*, deprecated, renamed: "items(cellIdentifier:cellType:source:configureCell:)")
    public func itemsWithCellIdentifier<S: Sequence, Cell: UITableViewCell, O : ObservableType where O.E == S>
        (_ cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (source: O)
        -> (configureCell: (Int, S.Iterator.Element, Cell) -> Void)
        -> Disposable {
        return { source in
            return { configureCell in
                let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S> { (tv, i, item) in
                    let indexPath = IndexPath(item: i, section: 0)
                    let cell = tv.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! Cell
                    configureCell(i, item, cell)
                    return cell
                }
                return self.itemsWithDataSource(dataSource)(source: source)
            }
        }
    }

    /**
    Binds sequences of elements to table view rows.
    
    - parameter cellIdentifier: Identifier used to dequeue cells.
    - parameter source: Observable sequence of items.
    - parameter configureCell: Transform between sequence elements and view cells.
    - parameter cellType: Type of table view cell.
    - returns: Disposable object that can be used to unbind.
     
     Example:

         let items = Observable.just([
             "First Item",
             "Second Item",
             "Third Item"
         ])

         items
             .bindTo(tableView.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
             }
             .addDisposableTo(disposeBag)
    */
    public func items<S: Sequence, Cell: UITableViewCell, O : ObservableType where O.E == S>
        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (source: O)
        -> (configureCell: (Int, S.Iterator.Element, Cell) -> Void)
        -> Disposable {
        return { source in
            return { configureCell in
                let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S> { (tv, i, item) in
                    let indexPath = IndexPath(item: i, section: 0)
                    let cell = tv.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! Cell
                    configureCell(i, item, cell)
                    return cell
                }
                return self.items(dataSource: dataSource)(source: source)
            }
        }
    }

    
    /**
    Binds sequences of elements to table view rows using a custom reactive data used to perform the transformation.
    This method will retain the data source for as long as the subscription isn't disposed (result `Disposable` 
    being disposed).
    In case `source` observable sequence terminates sucessfully, the data source will present latest element
    until the subscription isn't disposed.
    
    - parameter dataSource: Data source used to transform elements to view cells.
    - parameter source: Observable sequence of items.
    - returns: Disposable object that can be used to unbind.
     
     Example 

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>()

        let items = Observable.just([
            SectionModel(model: "First section", items: [
                1.0,
                2.0,
                3.0
                ]),
            SectionModel(model: "Second section", items: [
                1.0,
                2.0,
                3.0
                ]),
            SectionModel(model: "Third section", items: [
                1.0,
                2.0,
                3.0
                ])
            ])

        dataSource.configureCell = { (dataSource, tv, indexPath, element) in
        let cell = tv.dequeueReusableCellWithIdentifier("Cell")!
            cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
            return cell
        }

        items
            .bindTo(tableView.rx.itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
    */
    @available(*, deprecated, renamed: "rx_items(dataSource:source:)")
    public func itemsWithDataSource<
            DataSource: RxTableViewDataSourceType & UITableViewDataSource,
            O: ObservableType where DataSource.Element == O.E
        >
        (_ dataSource: DataSource)
        -> (source: O)
        -> Disposable  {
        return { source in
            // There needs to be a strong retaining here because
            return source.subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource, retainDataSource: true) { [weak tableView = self.base] (_: RxTableViewDataSourceProxy, event) -> Void in
                guard let tableView = tableView else {
                    return
                }
                dataSource.tableView(tableView, observedEvent: event)
            }
        }
    }


    /**
    Binds sequences of elements to table view rows using a custom reactive data used to perform the transformation.
    This method will retain the data source for as long as the subscription isn't disposed (result `Disposable` 
    being disposed).
    In case `source` observable sequence terminates sucessfully, the data source will present latest element
    until the subscription isn't disposed.
    
    - parameter dataSource: Data source used to transform elements to view cells.
    - parameter source: Observable sequence of items.
    - returns: Disposable object that can be used to unbind.
     
     Example 

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>()

        let items = Observable.just([
            SectionModel(model: "First section", items: [
                1.0,
                2.0,
                3.0
                ]),
            SectionModel(model: "Second section", items: [
                1.0,
                2.0,
                3.0
                ]),
            SectionModel(model: "Third section", items: [
                1.0,
                2.0,
                3.0
                ])
            ])

        dataSource.configureCell = { (dataSource, tv, indexPath, element) in
        let cell = tv.dequeueReusableCellWithIdentifier("Cell")!
            cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
            return cell
        }

        items
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    */
    public func items<
            DataSource: RxTableViewDataSourceType & UITableViewDataSource,
            O: ObservableType where DataSource.Element == O.E
        >
        (dataSource: DataSource)
        -> (source: O)
        -> Disposable  {
        return { source in
            // This is called for sideeffects only, and to make sure delegate proxy is in place when
            // data source is being bound.
            // This is needed because theoretically the data source subscription itself might
            // call `self.rx_delegate`. If that happens, it might cause weird side effects since
            // setting data source will set delegate, and UITableView might get into a weird state.
            // Therefore it's better to set delegate proxy first, just to be sure.
            _ = self.delegate
            // Strong reference is needed because data source is in use until result subscription is disposed
            return source.subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource, retainDataSource: true) { [weak tableView = self.base] (_: RxTableViewDataSourceProxy, event) -> Void in
                guard let tableView = tableView else {
                    return
                }
                dataSource.tableView(tableView, observedEvent: event)
            }
        }
    }

}

extension Reactive where Base: UITableView {
 
    /**
    Factory method that enables subclasses to implement their own `delegate`.
    
    - returns: Instance of delegate proxy that wraps `delegate`.
    */
    public func createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxTableViewDelegateProxy(parentObject: self.base)
    }

    /**
    Factory method that enables subclasses to implement their own `rx.dataSource`.
    
    - returns: Instance of delegate proxy that wraps `dataSource`.
    */
    public func createDataSourceProxy() -> RxTableViewDataSourceProxy {
        return RxTableViewDataSourceProxy(parentObject: self.base)
    }
    
    /**
    Reactive wrapper for `dataSource`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var dataSource: DelegateProxy {
        return RxTableViewDataSourceProxy.proxyForObject(base)
    }
   
    /**
    Installs data source as forwarding delegate on `rx.dataSource`.
    Data source won't be retained.
    
    It enables using normal delegate mechanism with reactive delegate mechanism.
     
    - parameter dataSource: Data source object.
    - returns: Disposable object that can be used to unbind the data source.
    */
    public func setDataSource(_ dataSource: UITableViewDataSource)
        -> Disposable {
        return RxTableViewDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self.base)
    }
    
    // events
    
    /**
    Reactive wrapper for `delegate` message `tableView:didSelectRowAtIndexPath:`.
    */
    public var itemSelected: ControlEvent<IndexPath> {
        let source = self.delegate.observe(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
            }

        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tableView:didDeselectRowAtIndexPath:`.
     */
    public var itemDeselected: ControlEvent<IndexPath> {
        let source = self.delegate.observe(#selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
            }

        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tableView:accessoryButtonTappedForRowWithIndexPath:`.
     */
    public var itemAccessoryButtonTapped: ControlEvent<IndexPath> {
        let source: Observable<IndexPath> = self.delegate.observe(#selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
            }
        
        return ControlEvent(events: source)
    }
    
    /**
    Reactive wrapper for `delegate` message `tableView:commitEditingStyle:forRowAtIndexPath:`.
    */
    public var itemInserted: ControlEvent<IndexPath> {
        let source = self.dataSource.observe(#selector(UITableViewDataSource.tableView(_:commit:forRowAt:)))
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (try castOrThrow(NSNumber.self, a[1])).intValue) == .insert
            }
            .map { a in
                return (try castOrThrow(IndexPath.self, a[2]))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
    Reactive wrapper for `delegate` message `tableView:commitEditingStyle:forRowAtIndexPath:`.
    */
    public var itemDeleted: ControlEvent<IndexPath> {
        let source = self.dataSource.observe(#selector(UITableViewDataSource.tableView(_:commit:forRowAt:)))
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (try castOrThrow(NSNumber.self, a[1])).intValue) == .delete
            }
            .map { a in
                return try castOrThrow(IndexPath.self, a[2])
            }
        
        return ControlEvent(events: source)
    }
    
    /**
    Reactive wrapper for `delegate` message `tableView:moveRowAtIndexPath:toIndexPath:`.
    */
    public var itemMoved: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = self.dataSource.observe(#selector(UITableViewDataSource.tableView(_:moveRowAt:to:)))
            .map { a in
                return (try castOrThrow(IndexPath.self, a[1]), try castOrThrow(IndexPath.self, a[2]))
            }
        
        return ControlEvent(events: source)
    }

    /**
    Reactive wrapper for `delegate` message `tableView:willDisplayCell:forRowAtIndexPath:`.
    */
    public var willDisplayCell: ControlEvent<WillDisplayCellEvent> {
        let source: Observable<WillDisplayCellEvent> = self.delegate.observe(#selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)))
            .map { a in
                return (try castOrThrow(UITableViewCell.self, a[1]), try castOrThrow(IndexPath.self, a[2]))
            }

        return ControlEvent(events: source)
    }

    /**
    Reactive wrapper for `delegate` message `tableView:didEndDisplayingCell:forRowAtIndexPath:`.
    */
    public var didEndDisplayingCell: ControlEvent<DidEndDisplayingCellEvent> {
        let source: Observable<DidEndDisplayingCellEvent> = self.delegate.observe(#selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:)))
            .map { a in
                return (try castOrThrow(UITableViewCell.self, a[1]), try castOrThrow(IndexPath.self, a[2]))
            }

        return ControlEvent(events: source)
    }

    /**
    Reactive wrapper for `delegate` message `tableView:didSelectRowAtIndexPath:`.
    
    It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
    or any other data source conforming to `SectionedViewDataSourceType` protocol.
    
     ```
        tableView.rx.modelSelected(MyModel.self)
            .map { ...
     ```
    */
    public func modelSelected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = self.itemSelected.flatMap { [weak view = self.base as UITableView] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }

            return Observable.just(try view.rx.modelAtIndexPath(indexPath))
        }
        
        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tableView:didDeselectRowAtIndexPath:`.

     It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
     or any other data source conforming to `SectionedViewDataSourceType` protocol.

     ```
        tableView.rx.modelDeselected(MyModel.self)
            .map { ...
     ```
     */
    public func modelDeselected<T>(_ modelType: T.Type) -> ControlEvent<T> {
         let source: Observable<T> = self.itemDeselected.flatMap { [weak view = self.base as UITableView] indexPath -> Observable<T> in
             guard let view = view else {
                 return Observable.empty()
             }

           return Observable.just(try view.rx.modelAtIndexPath(indexPath))
        }

        return ControlEvent(events: source)
    }

    /**
     Synchronous helper method for retrieving a model at indexPath through a reactive data source.
     */
    public func modelAtIndexPath<T>(_ indexPath: IndexPath) throws -> T {
        let dataSource: SectionedViewDataSourceType = castOrFatalError(self.dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx.items*` methods was used.")
        
        let element = try dataSource.modelAtIndexPath(indexPath)

        return castOrFatalError(element)
    }
}

#endif

#if os(tvOS)
    
    extension Reactive where Base: UITableView {
        
        /**
         Reactive wrapper for `delegate` message `tableView:didUpdateFocusInContext:withAnimationCoordinator:`.
         */
        public var didUpdateFocusInContextWithAnimationCoordinator: ControlEvent<(context: UIFocusUpdateContext, animationCoordinator: UIFocusAnimationCoordinator)> {
            
            let source = delegate.observe(#selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)))
                .map { a -> (context: UIFocusUpdateContext, animationCoordinator: UIFocusAnimationCoordinator) in
                    let context = a[1] as! UIFocusUpdateContext
                    let animationCoordinator = try castOrThrow(UIFocusAnimationCoordinator.self, a[2])
                    return (context: context, animationCoordinator: animationCoordinator)
            }
            
            return ControlEvent(events: source)
        }
    }
#endif
