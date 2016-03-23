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

extension UITableView {
    
    /**
    Binds sequences of elements to table view rows.
    
    - parameter source: Observable sequence of items.
    - parameter cellFactory: Transform between sequence elements and view cells.
    - returns: Disposable object that can be used to unbind.
    */
    public func rx_itemsWithCellFactory<S: SequenceType, O: ObservableType where O.E == S>
        (source: O)
        -> (cellFactory: (UITableView, Int, S.Generator.Element) -> UITableViewCell)
        -> Disposable {
        return { cellFactory in
            let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S>(cellFactory: cellFactory)
            
            return self.rx_itemsWithDataSource(dataSource)(source: source)
        }
    }

    /**
    Binds sequences of elements to table view rows.
    
    - parameter cellIdentifier: Identifier used to dequeue cells.
    - parameter source: Observable sequence of items.
    - parameter configureCell: Transform between sequence elements and view cells.
    - parameter cellType: Type of table view cell.
    - returns: Disposable object that can be used to unbind.
    */
    public func rx_itemsWithCellIdentifier<S: SequenceType, Cell: UITableViewCell, O : ObservableType where O.E == S>
        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (source: O)
        -> (configureCell: (Int, S.Generator.Element, Cell) -> Void)
        -> Disposable {
        return { source in
            return { configureCell in
                let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S> { (tv, i, item) in
                    let indexPath = NSIndexPath(forItem: i, inSection: 0)
                    let cell = tv.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
                    configureCell(i, item, cell)
                    return cell
                }
                return self.rx_itemsWithDataSource(dataSource)(source: source)
            }
        }
    }
    
    /**
    Binds sequences of elements to table view rows using a custom reactive data used to perform the transformation.
    
    - parameter dataSource: Data source used to transform elements to view cells.
    - parameter source: Observable sequence of items.
    - returns: Disposable object that can be used to unbind.
    */
    public func rx_itemsWithDataSource<DataSource: protocol<RxTableViewDataSourceType, UITableViewDataSource>, S: SequenceType, O: ObservableType where DataSource.Element == S, O.E == S>
        (dataSource: DataSource)
        -> (source: O)
        -> Disposable  {
        return { source in
            return source.subscribeProxyDataSourceForObject(self, dataSource: dataSource, retainDataSource: false) { [weak self] (_: RxTableViewDataSourceProxy, event) -> Void in
                guard let tableView = self else {
                    return
                }
                dataSource.tableView(tableView, observedEvent: event)
            }
        }
    }
}

extension UITableView {
 
    /**
    Factory method that enables subclasses to implement their own `rx_delegate`.
    
    - returns: Instance of delegate proxy that wraps `delegate`.
    */
    public override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxTableViewDelegateProxy(parentObject: self)
    }

    /**
    Factory method that enables subclasses to implement their own `rx_dataSource`.
    
    - returns: Instance of delegate proxy that wraps `dataSource`.
    */
    public func rx_createDataSourceProxy() -> RxTableViewDataSourceProxy {
        return RxTableViewDataSourceProxy(parentObject: self)
    }
    
    /**
    Reactive wrapper for `dataSource`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_dataSource: DelegateProxy {
        return proxyForObject(RxTableViewDataSourceProxy.self, self)
    }
   
    /**
    Installs data source as forwarding delegate on `rx_dataSource`.
    
    It enables using normal delegate mechanism with reactive delegate mechanism.
    
    - parameter dataSource: Data source object.
    - returns: Disposable object that can be used to unbind the data source.
    */
    public func rx_setDataSource(dataSource: UITableViewDataSource)
        -> Disposable {
        let proxy = proxyForObject(RxTableViewDataSourceProxy.self, self)
            
        return installDelegate(proxy, delegate: dataSource, retainDelegate: false, onProxyForObject: self)
    }
    
    // events
    
    /**
    Reactive wrapper for `delegate` message `tableView:didSelectRowAtIndexPath:`.
    */
    public var rx_itemSelected: ControlEvent<NSIndexPath> {
        let source = rx_delegate.observe(#selector(UITableViewDelegate.tableView(_:didSelectRowAtIndexPath:)))
            .map { a in
                return a[1] as! NSIndexPath
            }

        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tableView:didDeselectRowAtIndexPath:`.
     */
    public var rx_itemDeselected: ControlEvent<NSIndexPath> {
        let source = rx_delegate.observe(#selector(UITableViewDelegate.tableView(_:didDeselectRowAtIndexPath:)))
            .map { a in
                return a[1] as! NSIndexPath
            }

        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tableView:accessoryButtonTappedForRowWithIndexPath:`.
     */
    public var rx_itemAccessoryButtonTapped: ControlEvent<NSIndexPath> {
        let source: Observable<NSIndexPath> = rx_delegate.observe(#selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWithIndexPath:)))
            .map { a in
                return a[1] as! NSIndexPath
            }
        
        return ControlEvent(events: source)
    }
    
    /**
    Reactive wrapper for `delegate` message `tableView:commitEditingStyle:forRowAtIndexPath:`.
    */
    public var rx_itemInserted: ControlEvent<NSIndexPath> {
        let source = rx_dataSource.observe(#selector(UITableViewDataSource.tableView(_:commitEditingStyle:forRowAtIndexPath:)))
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Insert
            }
            .map { a in
                return (a[2] as! NSIndexPath)
        }
        
        return ControlEvent(events: source)
    }
    
    /**
    Reactive wrapper for `delegate` message `tableView:commitEditingStyle:forRowAtIndexPath:`.
    */
    public var rx_itemDeleted: ControlEvent<NSIndexPath> {
        let source = rx_dataSource.observe(#selector(UITableViewDataSource.tableView(_:commitEditingStyle:forRowAtIndexPath:)))
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Delete
            }
            .map { a in
                return (a[2] as! NSIndexPath)
            }
        
        return ControlEvent(events: source)
    }
    
    /**
    Reactive wrapper for `delegate` message `tableView:moveRowAtIndexPath:toIndexPath:`.
    */
    public var rx_itemMoved: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = rx_dataSource.observe(#selector(UITableViewDataSource.tableView(_:moveRowAtIndexPath:toIndexPath:)))
            .map { a in
                return ((a[1] as! NSIndexPath), (a[2] as! NSIndexPath))
            }
        
        return ControlEvent(events: source)
    }
    
    /**
    Reactive wrapper for `delegate` message `tableView:didSelectRowAtIndexPath:`.
    
    It can be only used when one of the `rx_itemsWith*` methods is used to bind observable sequence,
    or any other data source conforming to `SectionedViewDataSourceType` protocol.
    
     ```
        tableView.rx_modelSelected(MyModel.self)
            .map { ...
     ```
    */
    public func rx_modelSelected<T>(modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = rx_itemSelected.flatMap { [weak self] indexPath -> Observable<T> in
            guard let view = self else {
                return Observable.empty()
            }

            return Observable.just(try view.rx_modelAtIndexPath(indexPath))
        }
        
        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tableView:didDeselectRowAtIndexPath:`.

     It can be only used when one of the `rx_itemsWith*` methods is used to bind observable sequence,
     or any other data source conforming to `SectionedViewDataSourceType` protocol.

     ```
        tableView.rx_modelDeselected(MyModel.self)
            .map { ...
     ```
     */
    public func rx_modelDeselected<T>(modelType: T.Type) -> ControlEvent<T> {
         let source: Observable<T> = rx_itemDeselected.flatMap { [weak self] indexPath -> Observable<T> in
             guard let view = self else {
                 return Observable.empty()
             }

           return Observable.just(try view.rx_modelAtIndexPath(indexPath))
        }

        return ControlEvent(events: source)
    }

    /**
     Synchronous helper method for retrieving a model at indexPath through a reactive data source.
     */
    public func rx_modelAtIndexPath<T>(indexPath: NSIndexPath) throws -> T {
        let dataSource: SectionedViewDataSourceType = castOrFatalError(self.rx_dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx_items*` methods was used.")
        
        let element = try dataSource.modelAtIndexPath(indexPath)

        return castOrFatalError(element)
    }
}

#endif

#if os(tvOS)
    
    extension UITableView {
        
        /**
         Reactive wrapper for `delegate` message `tableView:didUpdateFocusInContext:withAnimationCoordinator:`.
         */
        public var rx_didUpdateFocusInContextWithAnimationCoordinator: ControlEvent<(context: UIFocusUpdateContext, animationCoordinator: UIFocusAnimationCoordinator)> {
            
            let source = rx_delegate.observe(#selector(UITableViewDelegate.tableView(_:didUpdateFocusInContext:withAnimationCoordinator:)))
                .map { a -> (context: UIFocusUpdateContext, animationCoordinator: UIFocusAnimationCoordinator) in
                    let context = a[1] as! UIFocusUpdateContext
                    let animationCoordinator = a[2] as! UIFocusAnimationCoordinator
                    return (context: context, animationCoordinator: animationCoordinator)
            }
            
            return ControlEvent(events: source)
        }
    }
#endif
