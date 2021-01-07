//
//  RuntimeStateSnapshot.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest

final class ObjectRuntimeState {
    let real: ClassRuntimeState
    let actingAs: ClassRuntimeState

    init(target: AnyObject) {
        assert(object_getClass(target)!.isSubclass(of: type(of: target)))
        real = ClassRuntimeState(object_getClass(target)!)
        actingAs = ClassRuntimeState(RXObjCTestRuntime.objCClass(target))
    }

    private static func changesFrom(_ from: ClassRuntimeState, to: ClassRuntimeState) -> [ObjectRuntimeChange] {
        if from.targetClass == to.targetClass {
            var changes = [ObjectRuntimeChange]()
            for (selector, implementation) in to.implementations {
                if let originalImplementation = from.implementations[selector] {
                    if originalImplementation != implementation {
                        if RXObjCTestRuntime.isForwardingIMP(implementation) {
                            changes.append(.implementationChangedToForwarding(forSelector: selector))
                        }
                        else {
                            changes.append(.implementationChanged(forSelector: selector))
                        }
                    }
                }
                else {
                    if RXObjCTestRuntime.isForwardingIMP(implementation) {
                        changes.append(.forwardImplementationAdded(forSelector: selector))
                    }
                    else {
                        changes.append(.implementationAdded(forSelector: selector))
                    }
                }
            }

            for (oldSelector, _) in from.implementations {
                if to.implementations[oldSelector] == nil {
                    changes.append(.implementationDeleted(forSelector: oldSelector))
                }
            }
            return changes
        }
        else {
            return [.classChanged(from: NSStringFromClass(from.targetClass), to: NSStringFromClass(to.targetClass), andImplementsTheseSelectors: Array(to.implementations.keys))]
        }
    }

    func changesFrom(_ initialState: ObjectRuntimeState) -> (real: [ObjectRuntimeChange], actingAs: [ObjectRuntimeChange]) {
        return (
            real: ObjectRuntimeState.changesFrom(initialState.real, to: self.real),
            actingAs: ObjectRuntimeState.changesFrom(initialState.actingAs, to: self.actingAs)
        )
    }

    func assertChangesFrom(_ initialState: ObjectRuntimeState, expectedActingClassChanges: [ObjectRuntimeChange], expectedRealClassChanges: [ObjectRuntimeChange]) {
        let changes = self.changesFrom(initialState)
        XCTAssertEqual(Set(changes.actingAs), Set(expectedActingClassChanges))
        if (Set(changes.actingAs) != Set(expectedActingClassChanges)) {
            print("Changes in actingAs class\nreal:\n\(changes.actingAs)\nexpected:\n\(expectedActingClassChanges)\n\n")
        }
        XCTAssertEqual(Set(changes.real), Set(expectedRealClassChanges))
        if (Set(changes.real) != Set(expectedRealClassChanges)) {
            print("Changes in actual class\nreal:\n\(changes.real)\nexpected:\n\(expectedRealClassChanges)\n\n")
        }
    }
}

enum ObjectRuntimeChange : Hashable {
    static func ClassChangedToDynamic(_ from: String, andImplementsTheseSelectors: [Selector]) -> ObjectRuntimeChange {
        .classChanged(from: from, to: "_RX_namespace_" + from, andImplementsTheseSelectors: andImplementsTheseSelectors)
    }

    case classChanged(from: String, to: String, andImplementsTheseSelectors: [Selector])
    case implementationChanged(forSelector: Selector)
    case implementationChangedToForwarding(forSelector: Selector)
    case implementationAdded(forSelector: Selector)
    case implementationDeleted(forSelector: Selector)
    case forwardImplementationAdded(forSelector: Selector)
}

extension ObjectRuntimeChange {
    func hash(into hasher: inout Hasher) {
        // who cares, this is not performance critical
        hasher.combine(0)
    }

    var isClassChange: Bool {
        if case .classChanged = self {
            return true
        }

        return false
    }
}

func ==(lhs: ObjectRuntimeChange, rhs: ObjectRuntimeChange) -> Bool {
    switch (lhs, rhs) {
    case let (.classChanged(lFrom, lTo, lImplementations), .classChanged(rFrom, rTo, rImplementations)):
        return (lFrom == rFrom && lTo == rTo) && Set(lImplementations) == Set(rImplementations)
    case let (.implementationChanged(lSelector), .implementationChanged(rSelector)):
        return lSelector == rSelector
    case let (.implementationChangedToForwarding(lSelector), .implementationChangedToForwarding(rSelector)):
        return lSelector == rSelector
    case let (.implementationAdded(lSelector), .implementationAdded(rSelector)):
        return lSelector == rSelector
    case let (.implementationDeleted(lSelector), .implementationDeleted(rSelector)):
        return lSelector == rSelector
    case let (.forwardImplementationAdded(lSelector), .forwardImplementationAdded(rSelector)):
        return lSelector == rSelector
    default:
        return false
    }
}

extension Sequence where Iterator.Element == ObjectRuntimeChange {
    var classChanged: Bool {
        return self.filter { x in
            if case .classChanged = x {
                return true
            } else {
                return false
            }
        }.count > 0
    }
}

struct ClassRuntimeState {
    let targetClass: AnyClass
    let implementations: [Selector: IMP]

    init(_ targetClass: AnyClass) {
        self.targetClass = targetClass
        self.implementations = ClassRuntimeState.implementationsBySelector(targetClass)
    }

    static func implementationsBySelector(_ klass: AnyClass) -> [Selector: IMP] {
        var count: UInt32 = 0
        let methods = class_copyMethodList(klass, &count)

        var result = [Selector: IMP]()
        for i in 0 ..< count {
            let method: Method = methods!.advanced(by: Int(i)).pointee
            result[method_getName(method)] = method_getImplementation(method)
        }

        return result
    }

}
