//
//  RxTextViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 7/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

// Please take a look at `DelegateProxyType.swift`
class RxTextViewDelegateProxy : RxScrollViewDelegateProxy
                               , UITextViewDelegate {
    
}

#endif
