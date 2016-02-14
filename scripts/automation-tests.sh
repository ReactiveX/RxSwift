#!/bin/bash
set -e

NUM_OF_TESTS=13
CURRENT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
BUILD_DIRECTORY=build
APP=RxExample
CONFIGURATIONS=(Debug Release-Tests Release)

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
	printf "${GREEN}Building example for automation ${BOLDCYAN}${SIMULATOR} - ${CONFIGURATION}${RESET}"
	echo

	rx $SCHEME $CONFIGURATION $SIMULATOR build

	echo
	printf "${GREEN}Quitting iOS Simulator ...${RESET}"
	echo

	osascript -e 'quit app "iOS Simulator.app"' > /dev/null

	if is_real_device "${SIMULATOR}"; then
        SIMULATOR_ID="${SIMULATOR}"
	else
        SIMULATOR_ID=`simulator_ids "${SIMULATOR}"`
    	echo
    	printf "${GREEN}Firing up simulator ${BOLDCYAN}${SIMULATOR}${GREEN}...${RESET}\n"
    	echo
        xcrun instruments -w ${SIMULATOR_ID} > /dev/null 2>&1 || echo
	fi

	echo
	if is_real_device "${SIMULATOR}"; then
		OUTPUT_DIR=${CONFIGURATION}-iphoneos
	else
		OUTPUT_DIR=${CONFIGURATION}-iphonesimulator
	fi
	APP_PATH="${BUILD_DIRECTORY}/Build/Products/${OUTPUT_DIR}/${APP}.app"
	printf "${GREEN}Installing the app ${BOLDCYAN}'${APP_PATH}'${GREEN} (${CONFIGURATION}) ${RESET}...\n"
	echo

	if is_real_device "${SIMULATOR}"; then
		/Users/kzaher/Projects/ios-deploy/ios-deploy --bundle "${APP_PATH}"
	else
		xcrun simctl install ${SIMULATOR_ID} "${APP_PATH}"
	fi

	pushd $TMPDIR
	rm -rf instrumentscli0.trace || echo
	echo
	printf "${GREEN}Running instruments ${BOLDCYAN}'${APP}'${GREEN}...${RESET}\n"
	echo

	OUTPUT="${TMPDIR}/output.txt"
	instruments -w "${SIMULATOR_ID}" -t Automation "${APP_PATH}" -e UIASCRIPT "${ROOT}/scripts/automation-tests/main.js" | tee "${OUTPUT}" #| grep "Pass" #|| (open instrumentscli0.trace; exit -1;)
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
	else
			printf "${GREEN}Automation says ok on ${BOLDCYAN}${SIMULATOR} - ${CONFIGURATION}${RESET}\n"
	fi
	popd
}

AUTOMATION_SIMULATORS=("Krunoslav Zaher’s iPhone" ${DEFAULT_IOS9_SIMULATOR})
#AUTOMATION_SIMULATORS=(${DEFAULT_IOS9_SIMULATOR})

IFS=""
for simulator in ${AUTOMATION_SIMULATORS[@]}
do
		for configuration in ${CONFIGURATIONS[@]}
		do
				runAutomation "RxExample-iOS" ${configuration} ${simulator}
		done
done
