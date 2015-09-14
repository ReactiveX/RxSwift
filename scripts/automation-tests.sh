#!/bin/bash
set -e

NUM_OF_TESTS=14
CURRENT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
BUILD_DIRECTORY=build
APP=RxExample
CONFIGURATIONS="Debug Release-Tests Release"

. scripts/common.sh

cd "${CURRENT_DIR}/.."

ROOT=`pwd`
BUILD_DIRECTORY="${ROOT}/build"

function runAutomation() {
	SCHEME=$1
	CONFIGURATION=$2
	SIMULATOR=$3

	APP="${SCHEME}"

	echo
	echo
	echo
	echo
	printf "${GREEN}Building example for automation ${BOLDCYAN}${SIMULATOR} - ${CONFIGURATION}${RESET}"
	echo

	rx $SCHEME $CONFIGURATION $SIMULATOR build

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
#for simulator in ${IOS7_SIMULATORS}
#do
#			for configuration in ${CONFIGURATIONS}
#			do
#					runAutomation "RxExample-iOS" ${configuration} ${simulator}
#			done
#done

# ios 8
for simulator in ${IOS8_SIMULATORS}
do
		for configuration in ${CONFIGURATIONS}
		do
				runAutomation "RxExample-iOS" ${configuration} ${simulator}
		done
done
