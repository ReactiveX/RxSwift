#!/bin/bash
set -e
#set -o xtrace

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

DEFAULT_IOS7_SIMULATOR=RxSwiftTest-iPhone4s-iOS_7.1
DEFAULT_IOS8_SIMULATOR=RxSwiftTest-iPhone6-iOS_8.4
DEFAULT_IOS9_SIMULATOR=RxSwiftTest-iPhone6-iOS_9.0

if [ "${IS_LOCAL}" -eq 1 ]; then
IOS7_SIMULATORS="RxSwiftTest-iPhone4s-iOS_7.1 RxSwiftTest-iPhone5-iOS_7.1 RxSwiftTest-iPhone5s-iOS_7.1"
IOS8_SIMULATORS="RxSwiftTest-iPhone4s-iOS_8.4 RxSwiftTest-iPhone5-iOS_8.4 RxSwiftTest-iPhone5s-iOS_8.4 RxSwiftTest-iPhone6-iOS_8.4 RxSwiftTest-iPhone6Plus-iOS_8.4"
#IOS9_SIMULATORS="RxSwiftTest-iPhone4s-iOS_9.0 RxSwiftTest-iPhone5-iOS_9.0 RxSwiftTest-iPhone5s-iOS_9.0 RxSwiftTest-iPhone6-iOS_9.0 RxSwiftTest-iPhone6Plus-iOS_9.0"
IOS9_SIMULATORS="RxSwiftTest-iPhone6-iOS_9.0"
else
IOS7_SIMULATORS="RxSwiftTest-iPhone4s-iOS_7.1"
IOS8_SIMULATORS="RxSwiftTest-iPhone4s-iOS_8.4"
#IOS9_SIMULATORS="RxSwiftTest-iPhone4s-iOS_9.0"
IOS9_SIMULATORS="RxSwiftTest-iPhone6-iOS_9.0"
fi


BUILD_DIRECTORY=build

function rx() {
	SCHEME=$1
	CONFIGURATION=$2
	SIMULATOR=$3
	ACTION=$4

	echo
	printf "${GREEN}${ACTION} ${BOLDCYAN}$1 - $2 ($SIMULATOR)${RESET}\n"
	echo

	DESTINATION=""
	if [ "$SIMULATOR" != "" ]; then
			OS=`echo $SIMULATOR| cut -d'_' -f 2`
			DESTINATION='platform=iOS Simulator,OS='$OS',name='$SIMULATOR''
	else
			DESTINATION='platform=OS X,arch=x86_64'
	fi

	STATUS=""
	xcodebuild -workspace Rx.xcworkspace \
				-scheme $SCHEME \
				-configuration $CONFIGURATION \
				-derivedDataPath "${BUILD_DIRECTORY}" \
				-destination "$DESTINATION" \
				$ACTION | xcpretty -c; STATUS=${PIPESTATUS[0]}

	if [ $STATUS -ne 0 ]; then
		echo $STATUS
 		exit $STATUS
	fi
}

# simulators

# xcrun simctl list devicetypes
# xcrun simctl list runtimes

function createDevices() {
	xcrun simctl create RxSwiftTest-iPhone4s-iOS_7.1 'iPhone 4s' 'com.apple.CoreSimulator.SimRuntime.iOS-7-1'
	xcrun simctl create RxSwiftTest-iPhone5-iOS_7.1 'iPhone 5' 'com.apple.CoreSimulator.SimRuntime.iOS-7-1'
	xcrun simctl create RxSwiftTest-iPhone5s-iOS_7.1 'iPhone 5s' 'com.apple.CoreSimulator.SimRuntime.iOS-7-1'

	xcrun simctl create RxSwiftTest-iPhone4s-iOS_8.4 'iPhone 4s' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'
	xcrun simctl create RxSwiftTest-iPhone5-iOS_8.4 'iPhone 5' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'
	xcrun simctl create RxSwiftTest-iPhone5s-iOS_8.4 'iPhone 5s' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'

	xcrun simctl create RxSwiftTest-iPhone6-iOS_8.4 'iPhone 6' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'
	xcrun simctl create RxSwiftTest-iPhone6Plus-iOS_8.4 'iPhone 6 Plus' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'

	xcrun simctl create RxSwiftTest-iPhone4s-iOS_9.0 'iPhone 4s' 'com.apple.CoreSimulator.SimRuntime.iOS-9-0'
	xcrun simctl create RxSwiftTest-iPhone5-iOS_9.0 'iPhone 5' 'com.apple.CoreSimulator.SimRuntime.iOS-9-0'
	xcrun simctl create RxSwiftTest-iPhone5s-iOS_9.0 'iPhone 5s' 'com.apple.CoreSimulator.SimRuntime.iOS-9-0'

	xcrun simctl create RxSwiftTest-iPhone6-iOS_9.0 'iPhone 6' 'com.apple.CoreSimulator.SimRuntime.iOS-9-0'
	xcrun simctl create RxSwiftTest-iPhone6Plus-iOS_9.0 'iPhone 6 Plus' 'com.apple.CoreSimulator.SimRuntime.iOS-9-0'
}

function deleteDevices() {
	xcrun simctl delete RxSwiftTest-iPhone4s-iOS_7.1 || echo "failed"
	xcrun simctl delete RxSwiftTest-iPhone5-iOS_7.1 || echo "failed"
	xcrun simctl delete RxSwiftTest-iPhone5s-iOS_7.1 || echo "failed"

	xcrun simctl delete RxSwiftTest-iPhone4s-iOS_8.4 || echo "failed"
	xcrun simctl delete RxSwiftTest-iPhone5-iOS_8.4 || echo "failed"
	xcrun simctl delete RxSwiftTest-iPhone5s-iOS_8.4 || echo "failed"

	xcrun simctl delete RxSwiftTest-iPhone6-iOS_8.4 || echo "failed"
	xcrun simctl delete RxSwiftTest-iPhone6Plus-iOS_8.4 || echo "failed"

	xcrun simctl delete RxSwiftTest-iPhone4s-iOS_9.0 || echo "failed"
	xcrun simctl delete RxSwiftTest-iPhone5-iOS_9.0 || echo "failed"
	xcrun simctl delete RxSwiftTest-iPhone5s-iOS_9.0 || echo "failed"

	xcrun simctl delete RxSwiftTest-iPhone6-iOS_9.0 || echo "failed"
	xcrun simctl delete RxSwiftTest-iPhone6Plus-iOS_9.0 || echo "failed"
}
