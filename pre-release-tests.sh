#!/bin/bash
set -e

CLEAN="clean"

if [ "$#" -eq 1 ]; then
	echo "Not cleaning up"
	CLEAN=""
else
	echo "Cleaning up first"
fi

echo "CLEAN=${CLEAN}"

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
	xcodebuild -workspace Rx.xcworkspace -scheme "$1" -configuration "$2" -derivedDataPath ${BUILD_DIRECTORY} ${CLEAN} test > /dev/null

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

	xcodebuild -workspace Rx.xcworkspace -scheme "$1" -configuration "$2" ${CLEAN} build > /dev/null
}

#runTests "RxTests-iOS" "Release-Tests"

#make sure all unit tests pass
for scheme in "RxTests-iOS" "RxTests-OSX" 
do
	for configuration in "Debug" "Release-Tests" "Release"
	do
		runTests ${scheme} ${configuration}
	done
done


# make sure it all build
for scheme in "RxExample-iOS" "RxExample-OSX" 
do
	for configuration in "Debug" "Release-Tests" "Release"
	do
		buildExample ${scheme} ${configuration}
	done
done

mdast -u mdast-slug -u mdast-validate-links ./*.md
mdast -u mdast-slug -u mdast-validate-links ./**/*.md
