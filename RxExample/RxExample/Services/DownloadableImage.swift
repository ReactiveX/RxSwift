//
//  DownloadableImage.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 10/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif

enum DownloadableImage{
    case content(image:Image)
    case offlinePlaceholder

}
