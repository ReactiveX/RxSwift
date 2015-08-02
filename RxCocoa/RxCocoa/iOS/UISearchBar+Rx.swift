//
//  UISearchBar+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit



extension UISearchBar {
    
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxSearchBarDelegateProxy
    }
    
    public var rx_searchText: Observable<String> {
        return defer { [weak self] in
            let text = self?.text ?? ""
            
            return self?.rx_delegate.observe("searchBar:textDidChange:") ?? empty()
                    >- map { a in
                        return a[1] as? String ?? ""
                    }
                    >- startWith(text)
        }
    }
}