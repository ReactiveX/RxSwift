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
    
    public var rx_searchText: ControlProperty<String> {
        let source: Observable<String> = deferred { [weak self] in
            let text = self?.text ?? ""
            
            return (self?.rx_delegate.observe("searchBar:textDidChange:") ?? empty())
                    .map { a in
                        return a[1] as? String ?? ""
                    }
                    .startWith(text)
        }
        
        return ControlProperty(source: source, observer: ObserverOf { [weak self] event in
            switch event {
            case .Next(let value):
                self?.text = value
            case .Error(let error):
                bindingErrorToInterface(error)
            case .Completed:
                break
            }
        })
    }
}