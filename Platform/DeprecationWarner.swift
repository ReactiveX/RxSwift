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
        private static var warned = [Kind]()
        private static var _lock = NSRecursiveLock()
        
        static func warnIfNeeded(_ kind: Kind) {
            _lock.lock(); defer { _lock.unlock() }
            guard !warned.contains(kind) else { return }
            
            warned.append(kind)
            print("ℹ️ [DEPRECATED] \(kind.message)")
        }
    }
    
    extension DeprecationWarner {
        enum Kind {
            case variable
            case globalTestFunction(String)
            
            var message: String {
                switch self {
                case .variable: return "`Variable` is planned for future deprecation. Please consider `RxCocoa.BehaviorRelay` as a replacement. Read more at: https://git.io/vNqvx"
                case .globalTestFunction(let name): return "The `\(name)()` global function is planned for future deprecation. Please use `Recorded.\(name)()` instead."
                }
            }
        }
    }
    
    extension DeprecationWarner.Kind: Equatable {}
    func ==(lhs: DeprecationWarner.Kind, rhs: DeprecationWarner.Kind) -> Bool {
        switch (lhs, rhs) {
        case (.variable, .variable): return true
        case let (.globalTestFunction(name1), .globalTestFunction(name2)): return name1 == name2
        default: return false
        }
    }
#endif

