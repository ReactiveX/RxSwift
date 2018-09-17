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

if [[ `uname` == "Darwin" ]]; then
    if [ `xcrun simctl list runtimes | grep com.apple.CoreSimulator.SimRuntime.iOS-11-3 | wc -l` -eq 1 ]; then
    	DEFAULT_IOS_SIMULATOR=RxSwiftTest/iPhone-6/iOS/11.3
    elif [ `xcrun simctl list runtimes | grep com.apple.CoreSimulator.SimRuntime.iOS-11-4 | wc -l` -eq 1 ]; then
    	DEFAULT_IOS_SIMULATOR=RxSwiftTest/iPhone-6/iOS/11.4
    else
    	DEFAULT_IOS_SIMULATOR=RxSwiftTest/iPhone-6/iOS/11.0
    fi

    if [ `xcrun simctl list runtimes | grep com.apple.CoreSimulator.SimRuntime.watchOS-4-3 | wc -l` -eq 1 ]; then
    	DEFAULT_WATCHOS_SIMULATOR=RxSwiftTest/Apple-Watch-38mm/watchOS/4.3
    elif [ `xcrun simctl list runtimes | grep com.apple.CoreSimulator.SimRuntime.watchOS-4-4 | wc -l` -eq 1 ]; then
    	DEFAULT_WATCHOS_SIMULATOR=RxSwiftTest/Apple-Watch-38mm/watchOS/4.4
    else
    	DEFAULT_WATCHOS_SIMULATOR=RxSwiftTest/Apple-Watch-38mm/watchOS/4.2
    fi

    if [ `xcrun simctl list runtimes | grep com.apple.CoreSimulator.SimRuntime.tvOS-11-3 | wc -l` -eq 1 ]; then
    	DEFAULT_TVOS_SIMULATOR=RxSwiftTest/Apple-TV-1080p/tvOS/11.3
    elif [ `xcrun simctl list runtimes | grep com.apple.CoreSimulator.SimRuntime.tvOS-11-4 | wc -l` -eq 1 ]; then
    	DEFAULT_TVOS_SIMULATOR=RxSwiftTest/Apple-TV-1080p/tvOS/11.4
    else
    	DEFAULT_TVOS_SIMULATOR=RxSwiftTest/Apple-TV-1080p/tvOS/11.0
    fi
fi
RUN_SIMULATOR_BY_NAME=0

function runtime_available() {
	if [ `xcrun simctl list runtimes | grep "${1}" | wc -l` -eq 1 ]; then
		return 0
	else
		return 1
	fi
}

# used to check simulator name
function contains() {
	string="$1"
	substring="$2"
	if [[ $string == *"$substring"* ]]
	then
		return 0    # $substring is in $string
	else
		return 1    # $substring is not in $string
	fi
}

function simulator_ids() {
	SIMULATOR=$1
	xcrun simctl list | grep "${SIMULATOR}" | cut -d "(" -f 2 | cut -d ")" -f 1 | sort | uniq
}

function simulator_available() {
	SIMULATOR=$1
	if [ `simulator_ids "${SIMULATOR}" | wc -l` -eq 0 ]; then
		return -1
	elif [ `simulator_ids "${SIMULATOR}" | wc -l` -gt 1 ]; then
		echo "Multiple simulators ${SIMULATOR} found"
		xcrun simctl list | grep "${SIMULATOR}"
		exit -1
	elif [ `xcrun simctl list | grep "${SIMULATOR}" | grep "unavailable" | wc -l` -gt 0 ]; then
		xcrun simctl list | grep "${SIMULATOR}" | grep "unavailable"
		exit -1
	else
		return 0
	fi
}

function is_real_device() {
	contains "$1" "’s "
}

function ensure_simulator_available() {
	SIMULATOR=$1

	if simulator_available "${SIMULATOR}"; then
		echo "${SIMULATOR} exists"
		return
	fi

	DEVICE=`echo "${SIMULATOR}" | cut -d "/" -f 2`
	OS=`echo "${SIMULATOR}" | cut -d "/" -f 3`
	VERSION_SUFFIX=`echo "${SIMULATOR}" | cut -d "/" -f 4 | sed -e "s/\./-/"`

	RUNTIME="com.apple.CoreSimulator.SimRuntime.${OS}-${VERSION_SUFFIX}"

	echo "Creating new simulator with runtime=${RUNTIME}"
	xcrun simctl create "${SIMULATOR}" "com.apple.CoreSimulator.SimDeviceType.${DEVICE}" "${RUNTIME}"

	SIMULATOR_ID=`simulator_ids "${SIMULATOR}"`
	echo "Warming up ${SIMULATOR_ID} ..."
	open -a "Simulator" --args -CurrentDeviceUDID "${SIMULATOR_ID}"
	sleep 120
}

BUILD_DIRECTORY=build

function rx() {
	action Rx.xcworkspace "$1" "$2" "$3" "$4"
}

function action() {
	WORKSPACE=$1
	SCHEME=$2
	CONFIGURATION=$3
	SIMULATOR=$4
	ACTION=$5

	echo
	printf "${GREEN}${ACTION} ${BOLDCYAN}$SCHEME - $CONFIGURATION ($SIMULATOR)${RESET}\n"
	echo

	DESTINATION=""
	if [ "${SIMULATOR}" != "" ]; then
		#if it's a real device
		if is_real_device "${SIMULATOR}"; then
			DESTINATION='name='${SIMULATOR}
			#else it's just a simulator
		else
			OS=`echo $SIMULATOR | cut -d '/' -f 3`
			if [ "${RUN_SIMULATOR_BY_NAME}" -eq 1 ]; then
				SIMULATOR_NAME=`echo $SIMULATOR | cut -d '/' -f 1`
				DESTINATION='platform='$OS' Simulator,name='$SIMULATOR_NAME''
			else
				ensure_simulator_available "${SIMULATOR}"
				SIMULATOR_GUID=`simulator_ids "${SIMULATOR}"`
				DESTINATION='platform='$OS' Simulator,OS='$OS',id='$SIMULATOR_GUID''
			fi
			echo "Running on ${DESTINATION}"
		fi
	else
		DESTINATION='platform=macOS,arch=x86_64'
	fi

	set -x
	mkdir -p build
	killall Simulator || true
	xcodebuild -workspace "${WORKSPACE}" \
		-scheme "${SCHEME}" \
		-configuration "${CONFIGURATION}" \
		-derivedDataPath "${BUILD_DIRECTORY}" \
		-destination "$DESTINATION" \
		$ACTION | tee build/last-build-output.txt | xcpretty -c
	exitIfLastStatusWasUnsuccessful
	set +x
}

function exitIfLastStatusWasUnsuccessful() {
	STATUS=${PIPESTATUS[0]}
	if [ $STATUS -ne 0 ]; then
		echo $STATUS
		exit $STATUS
	fi
}
