#!/bin/bash
set -e

RESET="\033[0m"
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
BOLDBLACK="\033[1m\033[30m"
BOLDRED="\033[1m\033[31m"
BOLDGREEN="\033[1m\033[32m"
BOLDYELLOW="\033[1m\033[33m"
BOLDBLUE="\033[1m\033[34m"
BOLDMAGENTA="\033[1m\033[35m"
BOLDCYAN="\033[1m\033[36m"
BOLDWHITE="\033[1m\033[37m"

# make sure all tests are passing

BUILD_DIRECTORY=build

function runTests() {
	echo
	printf "${GREEN}Running tests for ${BOLDCYAN}$1 - $2${RESET}\n"
	echo

	xcodebuild -workspace Rx.xcworkspace -scheme "$1" -configuration "$2" -derivedDataPath ${BUILD_DIRECTORY} test | xcpretty -c

	#if [[ $scheme == *"iOS"* ]]
	#then
	#	SDK="-sdk iphonesimulator"
	#fi
	#xctool -workspace Rx.xcworkspace -scheme "$1" -configuration "$2" ${SDK} -derivedDataPath  ${BUILD_DIRECTORY} test
}

function buildExample() {
	echo
	printf "${GREEN}Building example for ${BOLDCYAN}$1 - $2${RESET}\n"
	echo

	xcodebuild -workspace Rx.xcworkspace -scheme "$1" -configuration "$2" build | xcpretty -c
}

# simulators

# xcrun simctl list devicetypes
# xcrun simctl list runtimes

#IOS7_SIMULATORS="RxSwiftTest-iPhone4s-iOS_7.1 RxSwiftTest-iPhone5-iOS_7.1 RxSwiftTest-iPhone5s-iOS_7.1"
#IOS8_SIMULATORS="RxSwiftTest-iPhone4s-iOS_8.4 RxSwiftTest-iPhone5-iOS_8.4 RxSwiftTest-iPhone5s-iOS_8.4 RxSwiftTest-iPhone6-iOS_8.4 RxSwiftTest-iPhone6Plus-iOS_8.4"

function createDevices() {
	xcrun simctl create RxSwiftTest-iPhone4s-iOS_7.1 'iPhone 4s' 'com.apple.CoreSimulator.SimRuntime.iOS-7-1'
	xcrun simctl create RxSwiftTest-iPhone5-iOS_7.1 'iPhone 5' 'com.apple.CoreSimulator.SimRuntime.iOS-7-1'
	xcrun simctl create RxSwiftTest-iPhone5s-iOS_7.1 'iPhone 5s' 'com.apple.CoreSimulator.SimRuntime.iOS-7-1'

	xcrun simctl create RxSwiftTest-iPhone4s-iOS_8.4 'iPhone 4s' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'
	xcrun simctl create RxSwiftTest-iPhone5-iOS_8.4 'iPhone 5' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'
	xcrun simctl create RxSwiftTest-iPhone5s-iOS_8.4 'iPhone 5s' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'

	xcrun simctl create RxSwiftTest-iPhone6-iOS_8.4 'iPhone 6' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'
	xcrun simctl create RxSwiftTest-iPhone6Plus-iOS_8.4 'iPhone 6 Plus' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'
}

function deleteDevices() {
	xcrun simctl delete RxSwiftTest-iPhone4s-iOS_7.1
	xcrun simctl delete RxSwiftTest-iPhone5-iOS_7.1
	xcrun simctl delete RxSwiftTest-iPhone5s-iOS_7.1

	xcrun simctl delete RxSwiftTest-iPhone4s-iOS_8.4
	xcrun simctl delete RxSwiftTest-iPhone5-iOS_8.4
	xcrun simctl delete RxSwiftTest-iPhone5s-iOS_8.4

	xcrun simctl delete RxSwiftTest-iPhone6-iOS_8.4
	xcrun simctl delete RxSwiftTest-iPhone6Plus-iOS_8.4
}
