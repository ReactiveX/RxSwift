#!/bin/bash
set -e

for scheme in "RxTests-iOS" "RxTests-OSX" 
do
	for configuration in "Debug" "Release-Tests" "Release"
	do
		xcodebuild -workspace Rx.xcworkspace -scheme "${scheme}" -configuration "${configuration}" test
	done
done
