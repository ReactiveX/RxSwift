//
//  UIImageView+DownloadableImage.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 11/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
import UIKit

extension UIImageView{

    var rxex_downloadableImage: AnyObserver<DownloadableImage>{
        return self.rxex_downloadableImageAnimated(nil)
    }

    func rxex_downloadableImageAnimated(transitionType:String?) -> AnyObserver<DownloadableImage> {
        return UIBindingObserver(UIElement: self) { imageView, image in
            for subview in imageView.subviews {
                subview.removeFromSuperview()
            }
            switch image {
            case .Content(let image):
                imageView.rx_image.onNext(image)
            case .OfflinePlaceholder:
                let label = UILabel(frame: imageView.bounds)
                label.textAlignment = .Center
                label.font = UIFont.systemFontOfSize(35)
                label.text = "⚠️"
                imageView.addSubview(label)
            }
        }.asObserver()
    }
}
#endif
