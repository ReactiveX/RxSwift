#!/bin/bash

. scripts/common.sh

set -e
CURRENT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
BUILD_DIRECTORY=build
APP=RxExample
CONFIGURATIONS="Debug Release-Tests Release"
SIMULATORS="RxSwiftTest-iPhone6-iOS8.4"

echo "(Rx root ${CURRENT_DIR})"

cd "${CURRENT_DIR}"

CURRENT_DIR=`pwd`

function runAutomation() {
	SIMULATOR=$1
	CONFIGURATION=$2

	echo
	printf "${GREEN}Building example for automation ${BOLDCYAN}${SIMULATOR} - ${CONFIGURATION}${RESET}"
	echo

	xcodebuild -workspace Rx.xcworkspace -scheme RxExample-iOS -derivedDataPath ${BUILD_DIRECTORY} -configuration ${CONFIGURATION} -destination platform='iOS Simulator',name="${SIMULATOR}" build > /dev/null

	echo
	printf "${GREEN}Quitting iOS Simulator ...${RESET}"
	echo

	osascript -e 'quit app "iOS Simulator.app"' > /dev/null

	echo
	printf "${GREEN}Firing up simulator ${BOLDCYAN}${SIMULATOR}${GREEN}...${RESET}\n"
	echo

	xcrun instruments -w ${SIMULATOR} > /dev/null 2>&1 || echo

	echo
	printf "${GREEN}Installing the app ...${RESET}\n"
	echo

	xcrun simctl install ${SIMULATOR} ${BUILD_DIRECTORY}/Build/Products/${CONFIGURATION}-iphonesimulator/${APP}.app

	pushd $TMPDIR
	rm -rf instrumentscli0.trace || echo
	echo
	printf "${GREEN}Running instruments ...${RESET}\n"
	echo

	instruments -w ${SIMULATOR} -t Automation ${APP} -e UIASCRIPT $CURRENT_DIR/automation-tests/main.js #|| (open instrumentscli0.trace; exit -1;)
	echo "Instruments return value" $?
	popd
}

for simulator in ${SIMULATORS}
do
		for configuration in ${CONFIGURATIONS}
		do
			runAutomation ${simulator} ${configuration}
		done
done
