#!/bin/bash


set -e
NUM_OF_TESTS=14
CURRENT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
BUILD_DIRECTORY=build
APP=RxExample
CONFIGURATIONS="Debug Release-Tests Release"
#SIMULATORS="RxSwiftTest-iPhone4s-iOS_8.4 RxSwiftTest-iPhone5-iOS_8.4 RxSwiftTest-iPhone5s-iOS_8.4 RxSwiftTest-iPhone6-iOS_8.4 RxSwiftTest-iPhone6Plus-iOS_8.4 RxSwiftTest-iPhone4s-iOS_8.1 RxSwiftTest-iPhone5-iOS_8.1 RxSwiftTest-iPhone5s-iOS_8.1 RxSwiftTest-iPhone6-iOS_8.1 RxSwiftTest-iPhone6Plus-iOS_8.1"

#IOS7_SIMULATORS="RxSwiftTest-iPhone4s-iOS_7.1 RxSwiftTest-iPhone5-iOS_7.1 RxSwiftTest-iPhone5s-iOS_7.1"
IOS7_SIMULATORS=""
IOS8_SIMULATORS="RxSwiftTest-iPhone4s-iOS_8.4 RxSwiftTest-iPhone5-iOS_8.4 RxSwiftTest-iPhone5s-iOS_8.4 RxSwiftTest-iPhone6-iOS_8.4 RxSwiftTest-iPhone6Plus-iOS_8.4"

#open $TMPDIR

. scripts/common.sh

cd "${CURRENT_DIR}/.."

ROOT=`pwd`
BUILD_DIRECTORY="${ROOT}/build"

function runAutomation() {
	SIMULATOR=$1
	CONFIGURATION=$2
	SCHEME=$3

	APP="${SCHEME}"

	echo
	echo
	echo
	echo
	printf "${GREEN}Building example for automation ${BOLDCYAN}${SIMULATOR} - ${CONFIGURATION}${RESET}"
	echo

	OS=`echo $SIMULATOR| cut -d'_' -f 2`
	xcodebuild -workspace Rx.xcworkspace -scheme ${SCHEME} -derivedDataPath ${BUILD_DIRECTORY} -configuration ${CONFIGURATION} -destination platform='iOS Simulator',OS="${OS}",name="${SIMULATOR}" build | xcpretty -c

	echo
	printf "${GREEN}Quitting iOS Simulator ...${RESET}"
	echo

	osascript -e 'quit app "iOS Simulator.app"' > /dev/null

	echo
	printf "${GREEN}Firing up simulator ${BOLDCYAN}${SIMULATOR}${GREEN}...${RESET}\n"
	echo

	xcrun instruments -w ${SIMULATOR} > /dev/null 2>&1 || echo

	echo
	APP_PATH="${BUILD_DIRECTORY}/Build/Products/${CONFIGURATION}-iphonesimulator/${APP}.app"
	printf "${GREEN}Installing the app ${BOLDCYAN}'${APP_PATH}'${GREEN} ...${RESET}\n"
	echo

	xcrun simctl install ${SIMULATOR} "${APP_PATH}"

	pushd $TMPDIR
	rm -rf instrumentscli0.trace || echo
	echo
	printf "${GREEN}Running instruments ${BOLDCYAN}'${APP}'${GREEN}...${RESET}\n"
	echo

	OUTPUT="${TMPDIR}/output.txt"
	instruments -w ${SIMULATOR} -t Automation "${APP_PATH}" -e UIASCRIPT "${ROOT}/scripts/automation-tests/main.js" | tee "${OUTPUT}" #| grep "Pass" #|| (open instrumentscli0.trace; exit -1;)
	COUNT=`grep Pass: "$TMPDIR/output.txt" | wc -l`

	if [ "$COUNT" -lt "$NUM_OF_TESTS" ]; then
			echo
			printf "${RED}${SIMULATOR} - ${CONFIGURATION} tests do not pass${RESET}"
			echo
			cat "${OUTPUT}"
			echo
			printf "${RED}Only ${COUNT} of ${NUM_OF_TESTS} pass ${RESET}"
			echo
			open ./instrumentscli0.trace;
			exit -1;
	fi
	popd
}

# ios 7
for simulator in ${IOS7_SIMULATORS}
do
		for configuration in ${CONFIGURATIONS}
		do
			runAutomation ${simulator} ${configuration} "RxExample-iOS-no-module"
		done
done

# ios 8
for simulator in ${IOS8_SIMULATORS}
do
		for configuration in ${CONFIGURATIONS}
		do
			runAutomation ${simulator} ${configuration} "RxExample-iOS"
		done
done
