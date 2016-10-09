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
let excludedTests = [
    "testConcat_TailRecursionCollection",
    "testConcat_TailRecursionSequence",
    "testMapCompose_OptimizationIsPerformed",
    "testMapCompose_OptimizationIsNotPerformed",
    "testObserveOn_EnsureCorrectImplementationIsChosen",
    "testObserveOnDispatchQueue_EnsureCorrectImplementationIsChosen",
    "testWindowWithTimeOrCount_BasicPeriod",
    "testObserveOnDispatchQueue_DispatchQueueSchedulerIsSerial",
    "testResourceLeaksDetectionIsTurnedOn"
]

let excludedTestClasses = [
    "ObservableConcurrentSchedulerConcurrencyTest",
    "SubjectConcurrencyTest",
    "VirtualSchedulerTest",
    "HistoricalSchedulerTest"
]

let throwingWordsInTests = [
    "error",
    "fail",
    "throw",
    "retrycount",
    "retrywhen",
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

    print(targetPath)

    for file in try fileManager.contentsOfDirectory(atPath: targetPath)  {
        try checkExtension(file)

        print("Cleaning \(file)")
        try fileManager.removeItem(atPath: "\(targetPath)/\(file)")
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

            print("Linking \(fileName) [\(atURL)] -> \(destinationURL)")
            try fileManager.createSymbolicLink(at: atURL as URL, withDestinationURL: destinationURL as URL)
        }
    }
}

func buildAllTestsTarget(_ testsPath: String) throws {
    let splitClasses = "(?:class|extension)\\s+(\\w+)"
    let testMethods = "\\s+func\\s+(test\\w+)"

    let splitClassesRegularExpression = try! NSRegularExpression(pattern: splitClasses, options:[])
    let testMethodsExpression = try! NSRegularExpression(pattern: testMethods, options: [])

    var reducedMethods: [String: [String]] = [:]

    for file in try fileManager.contentsOfDirectory(atPath: testsPath) {
        if !file.hasSuffix(".swift") || file == "main.swift" {
            continue
        }

        let fileRelativePath = "\(testsPath)/\(file)"
        let testContent = try String(contentsOfFile: fileRelativePath, encoding: String.Encoding.utf8)

        print(fileRelativePath)

        let classMatches = splitClassesRegularExpression.matches(in: testContent as String, options: [], range: NSRange(location: 0, length: testContent.characters.count))
        let matchIndexes = classMatches
            .map { $0.range.location }
        let classNames = classMatches.map { (testContent as NSString).substring(with: $0.rangeAt(1)) as NSString }

        let ranges = zip([0] + matchIndexes, matchIndexes + [testContent.characters.count]).map { NSRange(location: $0, length: $1 - $0) }
        let classRanges = ranges[1 ..< ranges.count]

        let classes = zip(classNames, classRanges.map { (testContent as NSString).substring(with: $0) as NSString })

        for (name, classCode) in classes {
            if excludedTestClasses.contains(name as String) {
                print("Skipping \(name)")
                continue
            }

            let methodMatches = testMethodsExpression.matches(in: classCode as String, options: [], range: NSRange(location: 0, length: classCode.length))
            let methodNameRanges = methodMatches.map { $0.rangeAt(1) }
            let testMethodNames = methodNameRanges
                .map { classCode.substring(with: $0) }
                .filter { !excludedTests.contains($0) }

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

    for (name, methods) in reducedMethods {

        mainContent.append("")
        mainContent.append("let _\(name) = \(name)()")
        mainContent.append("_\(name).allTests = [")
        for method in methods {
            // throwing error on Linux, you will crash
            let isTestCaseHandlingError = throwingWordsInTests.map { (method as String).lowercased().contains($0) }.reduce(false) { $0 || $1 }
            mainContent.append("    \(isTestCaseHandlingError ? "//" : "")(\"\(method)\", { _\(name).setUp(); _\(name).\(method)(); _\(name).tearDown(); }),")
        }
        mainContent.append("]")
        mainContent.append("")
    }

    mainContent.append("CurrentThreadScheduler.instance.schedule(()) { _ in")
    mainContent.append("    XCTMain([")
    for testCase in reducedMethods.keys {
        mainContent.append("        _\(testCase),")
    }
    mainContent.append("    ])")
    mainContent.append("    return NopDisposable.instance")
    mainContent.append("}")
    mainContent.append("")

    let serializedMainContent = mainContent.joined(separator: "\n")
    try serializedMainContent.write(toFile: "\(testsPath)/main.swift", atomically: true, encoding: String.Encoding.utf8)
}


try packageRelativePath(["RxSwift"], targetDirName: "RxSwift")
//try packageRelativePath(["RxCocoa/Common", "RxCocoa/OSX", "RxCocoa/RxCocoa.h"], targetDirName: "RxCocoa")
try packageRelativePath(["RxCocoa/RxCocoa.h"], targetDirName: "RxCocoa")
try packageRelativePath(["RxBlocking"], targetDirName: "RxBlocking")
try packageRelativePath(["RxTests"], targetDirName: "RxTests")
// It doesn't work under `Tests` subpath ¯\_(ツ)_/¯
try packageRelativePath([
        "RxSwift/RxMutableBox.swift",
        "Tests/RxTest.swift",
        "Tests/Tests",
        "Tests/RxSwiftTests"
    ],
    targetDirName: "AllTests",
    excluded: [
        "Tests/VirtualSchedulerTest.swift",
        "Tests/HistoricalSchedulerTest.swift"
    ])

try buildAllTestsTarget("Sources/AllTests")

