#!/bin/bash


set -e
NUM_OF_TESTS=14
CURRENT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
BUILD_DIRECTORY=$TMPDIR/build
APP=RxExample
CONFIGURATIONS="Debug Release-Tests Release"
SIMULATORS="RxSwiftTest-iPhone4s-iOS_8.4 RxSwiftTest-iPhone5-iOS_8.4 RxSwiftTest-iPhone5s-iOS_8.4 RxSwiftTest-iPhone6-iOS_8.4 RxSwiftTest-iPhone6Plus-iOS_8.4 RxSwiftTest-iPhone4s-iOS_8.1 RxSwiftTest-iPhone5-iOS_8.1 RxSwiftTest-iPhone5s-iOS_8.1 RxSwiftTest-iPhone6-iOS_8.1 RxSwiftTest-iPhone6Plus-iOS_8.1"

open $TMPDIR

cd $CURRENT_DIR

. scripts/common.sh

echo "(Rx root ${CURRENT_DIR})"

cd "${CURRENT_DIR}"

CURRENT_DIR=`pwd`

function runAutomation() {
	SIMULATOR=$1
	CONFIGURATION=$2

	echo
	echo
	echo
	echo
	printf "${GREEN}Building example for automation ${BOLDCYAN}${SIMULATOR} - ${CONFIGURATION}${RESET}"
	echo

	OS=`echo $SIMULATOR| cut -d'_' -f 2`
	xcodebuild -workspace Rx.xcworkspace -scheme RxExample-iOS -derivedDataPath ${BUILD_DIRECTORY} -configuration ${CONFIGURATION} -destination platform='iOS Simulator',OS="${OS}",name="${SIMULATOR}" build > /dev/null

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

	instruments -w ${SIMULATOR} -t Automation ${APP} -e UIASCRIPT $CURRENT_DIR/automation-tests/main.js > $TMPDIR/output.txt #|| (open instrumentscli0.trace; exit -1;)
	COUNT=`grep Pass: $TMPDIR/output.txt | wc -l`

	if [ "$COUNT" -lt "$NUM_OF_TESTS" ]; then
			echo
			printf "${RED}${SIMULATOR} - ${CONFIGURATION} tests do not passes${RESET}"
			echo
			printf "${RED}Pases ${COUNT} tests of ${NUM_OF_TESTS} ${RESET}"
			echo
			open ./instrumentscli0.trace;
			exit;
	fi
	popd
}

for simulator in ${SIMULATORS}
do
		for configuration in ${CONFIGURATIONS}
		do
			runAutomation ${simulator} ${configuration}
		done
done
