//
//  DeprecationWarner.swift
//  Rx
//
//  Created by Shai Mishali on 1/9/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if DEBUG
    class DeprecationWarner {
        private static var warned = [String]()

        static func warnIfNeeded(_ message: String) {
            guard !warned.contains(message) else { return }

            warned.append(message)
            print("ℹ️ [DEPRECATED] \(message)")
        }
    }
#endif
