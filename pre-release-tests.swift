#!/usr/bin/env xcrun swift

import Foundation

func executeCommand(command: String, args: [String]! = nil) {
    let task = NSTask()

    task.launchPath = command
    task.arguments = args

    task.launch()
    task.waitUntilExit()

    if (task.terminationStatus != 0) {
	exit(task.terminationStatus)
    }
}

let target = "RxTests-iOS"

executeCommand("/usr/local/bin/xctool", args: [
	"-workspace", "Rx.xcworkspace", 
	"-scheme", target, 
	"-configuration", "Debug", 
	"-sdk", "iphonesimulator", 
	"-derivedDataPath", ".",
	"test"
])

