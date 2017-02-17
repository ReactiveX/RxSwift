//
//  RxSearchControllerResultsUpdaterProxy.swift
//  Rx
//
//  Created by André Vieira, Diego Chohfi on 17/02/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
    
#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit
    
/// For more information take a look at `DelegateProxyType`.
@available(iOS 8.0, *)
public class RxSearchControllerResultsUpdaterProxy
    : DelegateProxy
    , DelegateProxyType
    , UISearchResultsUpdating {
    
    public let searchControllerSubject = PublishSubject<UISearchController>()
    
    deinit {
        self.searchControllerSubject.onCompleted()
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        self.searchControllerSubject.onNext(searchController)
        self._forwardToDelegate?.updateSearchResults(for: searchController)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let searchController: UISearchController = castOrFatalError(object)
        return searchController.createSearchResultsUpdaterProxy()
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let searchController: UISearchController = castOrFatalError(object)
        searchController.searchResultsUpdater = castOptionalOrFatalError(delegate)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let searchController: UISearchController = castOrFatalError(object)
        return searchController.searchResultsUpdater
    }
}

#endif
