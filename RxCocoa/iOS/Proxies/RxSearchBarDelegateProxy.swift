//
//  RxSearchBarDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

public class RxSearchBarDelegateProxy : DelegateProxy
                               , UISearchBarDelegate
                               , DelegateProxyType {
    
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let searchBar: UISearchBar = castOrFatalError(object)
        return searchBar.delegate
    }
    
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let searchBar: UISearchBar = castOrFatalError(object)
        searchBar.delegate = castOptionalOrFatalError(delegate)
    }

    // MARK: Delegate proxy methods
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let searchBar = (object as! UISearchBar)
        
        return castOrFatalError(searchBar.rx_createDelegateProxy())
    }
}

#endif
