//
//  CollectionViewImageCell.swift
//  Example
//
//  Created by Krunoslav Zaher on 4/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public class CollectionViewImageCell: UICollectionViewCell {
    @IBOutlet var imageOutlet: UIImageView!
    
    var disposeBag: DisposeBag?

    var downloadableImage: Observable<DownloadableImage>?{
        didSet{
            let disposeBag = DisposeBag()

            self.downloadableImage?
                .asDriver(onErrorJustReturn: DownloadableImage.OfflinePlaceholder)
                .drive(imageOutlet.rxex_downloadableImageAnimated(kCATransitionFade))
                .addDisposableTo(disposeBag)

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