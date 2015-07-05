//
//  CollectionViewImageCell.swift
//  Example
//
//  Created by Krunoslav Zaher on 4/4/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public class CollectionViewImageCell: UICollectionViewCell {
    @IBOutlet var imageOutlet: UIImageView!
    
    var disposeBag: DisposeBag!
    
    var image: Observable<UIImage?>! {
        didSet {
            let disposeBag = DisposeBag()
            
            self.image >- imageOutlet.rx_subscribeImageTo(true) >- disposeBag.addDisposable
            
            self.disposeBag = disposeBag
        }
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }

    deinit {
    }
}