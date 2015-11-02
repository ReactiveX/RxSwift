//
//  DownloadableImage.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 31.10.2015.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

enum DownloadableImage{
    case Content(image:Image)
    case OfflinePlaceholder

}
