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

class RxSearchBarDelegateProxy : DelegateProxy
                               , UISearchBarDelegate
                               , DelegateProxyType {
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let searchBar: UISearchBar = castOrFatalError(object)
        return searchBar.delegate
    }
    
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let searchBar: UISearchBar = castOrFatalError(object)
        searchBar.delegate = castOptionalOrFatalError(delegate)
    }
}

#endif
