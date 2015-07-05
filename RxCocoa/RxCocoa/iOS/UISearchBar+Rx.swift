//
//  UISearchBar+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit



extension UISearchBar {
    
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxSearchBarDelegateProxy
    }
    
    public var rx_searchText: Observable<String> {
        return rx_delegate.observe("searchBar:textDidChange:")
            >- map { a in
                return a[1] as? String ?? ""
            }
    }
}