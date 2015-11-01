//
//  DownloadableImage.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 31.10.2015.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

public enum DownloadableImage{
    case Content(image:UIImage)
    case OfflinePlaceholder

}

extension UIImageView{

    public var rxex_downloadableImage: AnyObserver<DownloadableImage>{
        return self.rxex_downloadableImageAnimated(nil)
    }

    public func rxex_downloadableImageAnimated(transitionType:String?) -> AnyObserver<DownloadableImage> {

        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event{
            case .Next(let value):
                for subview in self?.subviews ?? [] {
                    subview.removeFromSuperview()
                }
                switch value{
                case .Content(let image):
                    self?.rx_image.onNext(image)
                case .OfflinePlaceholder:
                    let label = UILabel(frame: self!.frame)
                    label.textAlignment = .Center
                    label.font = UIFont.systemFontOfSize(35)
                    label.text = "⚠️📶"
                    self?.addSubview(label)
                }
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }
}

#endif
