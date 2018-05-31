//
//  UITableViewCell+Rx.swift
//  RxCocoa
//
//  Created by Mohammadreza Hemmati on 5/31/2018 AP.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import UIKit
import ObjectiveC
import RxSwift
import RxCocoa

private var disposeBagKey: UInt8 = 0

fileprivate extension UITableViewCell{
    
    func diposeOnReuse(){
        objc_setAssociatedObject(self, &disposeBagKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
}

extension Reactive where Base : UITableViewCell {

    var diposeOnReuseDisposeBag : DisposeBag {
        
        guard let disposeBag =  objc_getAssociatedObject(base, &disposeBagKey) as? DisposeBag else{
            let disposeBag = DisposeBag()
            objc_setAssociatedObject(base, &disposeBagKey, disposeBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            methodInvoked(#selector(Base.prepareForReuse)).subscribe(onNext: { [weak base] (_) in
                base?.diposeOnReuse()
            }).disposed(by: disposeBag)
            return disposeBag
        }
        
        return disposeBag
    }
    
}
