#!/usr/bin/swift
//
//  package-swift-manager.swift
//  
//
//  Created by Krunoslav Zaher on 12/26/15.
//
//

import Foundation

// It is kind of ironic that we need to additionally package for package manager :/

let fileManager = NSFileManager.defaultManager()

let allowedExtensions = [".swift", ".h", ".m"]

func isExtensionAllowed(path: String) -> Bool {
    return (allowedExtensions.map { path.hasSuffix($0) }).reduce(false) { $0 || $1 }
}

func checkExtension(path: String) throws {
    if !isExtensionAllowed(path) {
        throw NSError(domain: "Security", code: -1, userInfo: ["path" : path])
    }
}

func packageRelativePath(paths: [String], targetDirName: String) throws {
    let targetPath = "Sources/\(targetDirName)"

    print(targetPath)

    for file in try fileManager.contentsOfDirectoryAtPath(targetPath)  {
        try checkExtension(file)

        print("Cleaning \(file)")
        try fileManager.removeItemAtPath("\(targetPath)/\(file)")
    }

    for sourcePath in paths {
        var isDirectory: ObjCBool = false
        fileManager.fileExistsAtPath(sourcePath, isDirectory: &isDirectory)

        let files = isDirectory ? try fileManager.subpathsOfDirectoryAtPath(sourcePath)
                : [sourcePath]

        for file in files {
            if !isExtensionAllowed(file) {
                continue
            }

            let fileRelativePath = isDirectory ? "\(sourcePath)/\(file)" : file

            let destinationURL = NSURL(string: "../../\(fileRelativePath)")!

            let fileName = (file as NSString).lastPathComponent
            let atURL = NSURL(string: "file:///\(fileManager.currentDirectoryPath)/\(targetPath)/\(fileName)")!

            print("Linking \(fileName) [\(atURL)] -> \(destinationURL)")
            try fileManager.createSymbolicLinkAtURL(atURL, withDestinationURL: destinationURL)
        }
    }
}

try packageRelativePath(["RxSwift"], targetDirName: "RxSwift")
try packageRelativePath(["RxCocoa/Common", "RxCocoa/OSX", "RxCocoa/RxCocoa.h"], targetDirName: "RxCocoa")
try packageRelativePath(["RxBlocking"], targetDirName: "RxBlocking")
try packageRelativePath(["RxTests"], targetDirName: "RxTests")
// It doesn't work under `Tests` subpath ¯\_(ツ)_/¯
try packageRelativePath(["Tests"], targetDirName: "AllTests")