#!/bin/bash
set -e

CLEAN="clean"

echo "$#"

if [ "$#" -eq 1 ]; then
	CLEAN=""
fi

# make sure all tests are passing
for scheme in "RxTests-iOS" "RxTests-OSX" 
do
	for configuration in "Debug" "Release-Tests" "Release"
	do
		xcodebuild -workspace Rx.xcworkspace -scheme "${scheme}" -configuration "${configuration}" ${CLEAN} test
	done
done


# make sure it all build
for scheme in "RxExample-iOS" "RxExample-OSX" 
do
	for configuration in "Debug" "Release-Tests" "Release"
	do
		xcodebuild -workspace Rx.xcworkspace -scheme "${scheme}" -configuration "${configuration}" ${CLEAN} build
	done
done

mdast -u mdast-slug -u mdast-validate-links ./*.md
mdast -u mdast-slug -u mdast-validate-links ./**/*.md
