#!/usr/bin/swift
//
//  package-spm.swift
//  scripts
//
//  Created by Krunoslav Zaher on 12/26/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
 This script packages normal Rx* structure into `Sources` directory.

 * creates and updates links to normal project structure
 * builds unit tests `main.swift`

 Unfortunately, Swift support for Linux, libdispatch and package manager are still quite unstable,
 so certain class of unit tests is excluded for now.

 */

// It is kind of ironic that we need to additionally package for package manager :/

let fileManager = FileManager.default

let allowedExtensions = [
    ".swift",
    ".h",
    ".m",
]
// Those tests are dependent on conditional compilation logic and it's hard to handle them automatically
// They usually test some internal state, so it should be ok to exclude them for now.
let excludedTests: [String] = [
    "testConcat_TailRecursionCollection",
    "testConcat_TailRecursionSequence",
    "testMapCompose_OptimizationIsPerformed",
    "testMapCompose_OptimizationIsNotPerformed",
    "testObserveOn_EnsureCorrectImplementationIsChosen",
    "testObserveOnDispatchQueue_EnsureCorrectImplementationIsChosen",
    "testResourceLeaksDetectionIsTurnedOn",
    "testAnonymousObservable_disposeReferenceDoesntRetainObservable",
    "testObserveOnDispatchQueue_DispatchQueueSchedulerIsSerial",
    "ReleasesResourcesOn",
    "testShareReplayLatestWhileConnectedDisposableDoesntRetainAnything",
    "testSingle_DecrementCountsFirst",
    "testSinglePredicate_DecrementCountsFirst",
    "testLockUnlockCountsResources"
]

func excludeTest(_ name: String) -> Bool {
    for exclusion in excludedTests {
        if name.contains(exclusion) {
            return true
        }
    }

    return false
}

let excludedTestClasses: [String] = [
    /*"ObservableConcurrentSchedulerConcurrencyTest",
    "SubjectConcurrencyTest",
    "VirtualSchedulerTest",
    "HistoricalSchedulerTest"*/
    "BagTest"
]

let throwingWordsInTests: [String] = [
    /*"error",
    "fail",
    "throw",
    "retrycount",
    "retrywhen",*/
]

func isExtensionAllowed(_ path: String) -> Bool {
    return (allowedExtensions.map { path.hasSuffix($0) }).reduce(false) { $0 || $1 }
}

func checkExtension(_ path: String) throws {
    if !isExtensionAllowed(path) {
        throw NSError(domain: "Security", code: -1, userInfo: ["path" : path])
    }
}

func packageRelativePath(_ paths: [String], targetDirName: String, excluded: [String] = []) throws {
    let targetPath = "Sources/\(targetDirName)"

    print("Checking " + targetPath)

    for file in try fileManager.contentsOfDirectory(atPath: targetPath).sorted { $0 < $1 }  {
        if file != "include" && file != ".DS_Store" {
            print("Checking extension \(file)")
            try checkExtension(file)

            print("Cleaning \(file)")
            try fileManager.removeItem(atPath: "\(targetPath)/\(file)")
        }
    }

    for sourcePath in paths {
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: sourcePath, isDirectory: &isDirectory)

        let files: [String] = isDirectory.boolValue ? fileManager.subpaths(atPath: sourcePath)!
            : [sourcePath]

        for file in files {
            if !isExtensionAllowed(file) {
                print("Skipping \(file)")
                continue
            }

            if excluded.contains(file) {
                print("Skipping \(file)")
                continue
            }

            let fileRelativePath = isDirectory.boolValue ? "\(sourcePath)/\(file)" : file

            let destinationURL = NSURL(string: "../../\(fileRelativePath)")!

            let fileName = (file as NSString).lastPathComponent
            let atURL = NSURL(string: "file:///\(fileManager.currentDirectoryPath)/\(targetPath)/\(fileName)")!

            if fileName.hasSuffix(".h") {
                let sourcePath = NSURL(string: "file:///" + fileManager.currentDirectoryPath + "/" + sourcePath + "/" + file)!
                //throw NSError(domain: sourcePath.description, code: -1, userInfo: nil)
                try fileManager.copyItem(at: sourcePath as URL, to: atURL as URL)
            }
            else {
                print("Linking \(fileName) [\(atURL)] -> \(destinationURL)")
                try fileManager.createSymbolicLink(at: atURL as URL, withDestinationURL: destinationURL as URL)
            }
        }
    }
}

func buildAllTestsTarget(_ testsPath: String) throws {
    let splitClasses = "(?:class|extension)\\s+(\\w+)"
    let testMethods = "\\s+func\\s+(test\\w+)"

    let splitClassesRegularExpression = try! NSRegularExpression(pattern: splitClasses, options:[])
    let testMethodsExpression = try! NSRegularExpression(pattern: testMethods, options: [])

    var reducedMethods: [String: [String]] = [:]

    for file in try fileManager.contentsOfDirectory(atPath: testsPath).sorted { $0 < $1 } {
        if !file.hasSuffix(".swift") || file == "main.swift" {
            continue
        }

        let fileRelativePath = "\(testsPath)/\(file)"
        let testContent = try String(contentsOfFile: fileRelativePath, encoding: String.Encoding.utf8)

        print(fileRelativePath)

        let classMatches = splitClassesRegularExpression.matches(in: testContent as String, options: [], range: NSRange(location: 0, length: testContent.characters.count))
        let matchIndexes = classMatches
            .map { $0.range.location }

        #if swift(>=4.0)
            let classNames = classMatches.map { (testContent as NSString).substring(with: $0.range(at: 1)) as NSString }
        #else
            let classNames = classMatches.map { (testContent as NSString).substring(with: $0.rangeAt(1)) as NSString }
        #endif

        let ranges = zip([0] + matchIndexes, matchIndexes + [testContent.characters.count]).map { NSRange(location: $0, length: $1 - $0) }
        let classRanges = ranges[1 ..< ranges.count]

        let classes = zip(classNames, classRanges.map { (testContent as NSString).substring(with: $0) as NSString })

        for (name, classCode) in classes {
            if excludedTestClasses.contains(name as String) {
                print("Skipping \(name)")
                continue
            }

            let methodMatches = testMethodsExpression.matches(in: classCode as String, options: [], range: NSRange(location: 0, length: classCode.length))

            #if swift(>=4.0)
                let methodNameRanges = methodMatches.map { $0.range(at: 1) }
            #else
                let methodNameRanges = methodMatches.map { $0.rangeAt(1) }
            #endif

            let testMethodNames = methodNameRanges
                .map { classCode.substring(with: $0) }
                .filter { !excludeTest($0) }

            if testMethodNames.count == 0 {
                continue
            }

            let existingMethods = reducedMethods[name as String] ?? []
            reducedMethods[name as String] = existingMethods + testMethodNames
        }
    }

    var mainContent = [String]()

    mainContent.append("// this file is autogenerated using `./scripts/package-swift-manager.swift`")
    mainContent.append("import XCTest")
    mainContent.append("import RxSwift")
    mainContent.append("")
    mainContent.append("protocol RxTestCase {")
    mainContent.append("#if os(macOS)")
    mainContent.append("    init()")
    mainContent.append("    static var allTests: [(String, (Self) -> () -> ())] { get }")
    mainContent.append("#endif")
    mainContent.append("    func setUp()")
    mainContent.append("    func tearDown()")
    mainContent.append("}")
    mainContent.append("")

    for (name, methods) in reducedMethods {

        mainContent.append("")
        mainContent.append("final class \(name)_ : \(name), RxTestCase {")
        mainContent.append("    #if os(macOS)")
        mainContent.append("    required override init() {")
        mainContent.append("        super.init()")
        mainContent.append("    }")
        mainContent.append("    #endif")
        mainContent.append("")
        mainContent.append("    static var allTests: [(String, (\(name)_) -> () -> ())] { return [")
        for method in methods {
            // throwing error on Linux, you will crash
            let isTestCaseHandlingError = throwingWordsInTests.map { (method as String).lowercased().contains($0) }.reduce(false) { $0 || $1 }
            mainContent.append("    \(isTestCaseHandlingError ? "//" : "")(\"\(method)\", \(name).\(method)),")
        }
        mainContent.append("    ] }")
        mainContent.append("}")
    }

    mainContent.append("#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)")
    mainContent.append("")
    mainContent.append("func testCase<T: RxTestCase>(_ tests: [(String, (T) -> () -> ())]) -> () -> () {")
    mainContent.append("    return {")
    mainContent.append("        for testCase in tests {")
    mainContent.append("            print(\"Test \\(testCase)\")")
    mainContent.append("            for test in T.allTests {")
    mainContent.append("                let testInstance = T()")
    mainContent.append("                testInstance.setUp()")
    mainContent.append("                print(\"   testing \\(test.0)\")")
    mainContent.append("                test.1(testInstance)()")
    mainContent.append("                testInstance.tearDown()")
    mainContent.append("            }")
    mainContent.append("        }")
    mainContent.append("    }")
    mainContent.append("}")
    mainContent.append("")
    mainContent.append("func XCTMain(_ tests: [() -> ()]) {")
    mainContent.append("    for testCase in tests {")
    mainContent.append("        testCase()")
    mainContent.append("    }")
    mainContent.append("}")
    mainContent.append("")
    mainContent.append("#endif")
    mainContent.append("")
    mainContent.append("    XCTMain([")
    for testCase in reducedMethods.keys {
        mainContent.append("        testCase(\(testCase)_.allTests),")
    }
    mainContent.append("    ])")
    mainContent.append("//}")
    mainContent.append("")

    let serializedMainContent = mainContent.joined(separator: "\n")
    try serializedMainContent.write(toFile: "\(testsPath)/main.swift", atomically: true, encoding: String.Encoding.utf8)
}


try packageRelativePath(["RxSwift"], targetDirName: "RxSwift")
//try packageRelativePath(["RxCocoa/Common", "RxCocoa/macOS", "RxCocoa/RxCocoa.h"], targetDirName: "RxCocoa")

try packageRelativePath([
    "RxCocoa/RxCocoa.swift",
    "RxCocoa/Deprecated.swift",
    "RxCocoa/Traits",
    "RxCocoa/Common",
    "RxCocoa/Foundation",
    "RxCocoa/iOS",
    "RxCocoa/macOS",
    "RxCocoa/Platform",
    ], targetDirName: "RxCocoa")
try packageRelativePath([
    "RxCocoa/Runtime/include",
    ], targetDirName: "RxCocoaRuntime/include")
try packageRelativePath([
    "RxCocoa/Runtime/_RX.m",
    "RxCocoa/Runtime/_RXDelegateProxy.m",
    "RxCocoa/Runtime/_RXKVOObserver.m",
    "RxCocoa/Runtime/_RXObjCRuntime.m",
    ], targetDirName: "RxCocoaRuntime")

try packageRelativePath(["RxBlocking"], targetDirName: "RxBlocking")
try packageRelativePath(["RxTest"], targetDirName: "RxTest")
// It doesn't work under `Tests` subpath ¯\_(ツ)_/¯
try packageRelativePath([
        "Tests/RxSwiftTests",
        "Tests/RxBlockingTests",
        "RxSwift/RxMutableBox.swift",
        "Tests/RxTest.swift",
        "Tests/Recorded+Timeless.swift",
        "Tests/TestErrors.swift",
        "Tests/XCTest+AllTests.swift",
        "Platform",
        "Tests/RxCocoaTests/Driver+Test.swift",
        "Tests/RxCocoaTests/Signal+Test.swift",
        "Tests/RxCocoaTests/SharedSequence+Extensions.swift",
        "Tests/RxCocoaTests/SharedSequence+Test.swift",
        "Tests/RxCocoaTests/SharedSequence+OperatorTest.swift",
        "Tests/RxCocoaTests/NotificationCenterTests.swift",
    ],
    targetDirName: "AllTestz",
    excluded: [
        "Tests/VirtualSchedulerTest.swift",
        "Tests/HistoricalSchedulerTest.swift",
        // @testable import doesn't work well in Linux :/
        "QueueTests.swift",
        // @testable import doesn't work well in Linux :/
        "SubjectConcurrencyTest.swift",
        // @testable import doesn't work well in Linux :/
        "BagTest.swift"
    ])

try buildAllTestsTarget("Sources/AllTestz")

