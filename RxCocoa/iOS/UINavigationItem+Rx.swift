//
//  UINavigationItem+Rx.swift
//  RxCocoa
//
//  Created by kumapo on 2016/05/09.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
import UIKit
import RxSwift
    
extension Reactive where Base: UINavigationItem {
    
    /// Bindable sink for `title` property.
    public var title: Binder<String?> {
        return Binder(self.base) { navigationItem, text in
            navigationItem.title = text
        }
    }
    
    /// Bindable sink for `prompt` property.
    public var prompt: Binder<String?> {
        return Binder(self.base) { navigationItem, prompt in
            navigationItem.prompt = prompt
        }
    }
        
}
    
#endif
