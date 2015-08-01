#!/bin/bash

set -e

CURRENT_DIR="$( dirname "${BASH_SOURCE[0]}" )"

cd $CURRENT_DIR

RxSwiftTest='iPhone 6 Plus'

xcodebuild -workspace Rx.xcworkspace -scheme RxExample-iOS -derivedDataPath $TMPDIR/build -configuration Release -destination name='iPhone 6 Plus' build

osascript -e 'quit app "iOS Simulator.app"'

xcrun instruments -w 'iPhone 6 Plus' > /dev/null 2>&1 || echo

sleep 2

xcrun simctl install 'iPhone 6 Plus' $TMPDIR/build/Build/Products/Release-iphonesimulator/RxExample.app

sleep 10

cd $TMPDIR

rm -rf instrumentscli0.trace || echo

instruments -w 'iPhone 6 Plus' -t Automation RxExample -e UIASCRIPT $CURRENT_DIR/automation-tests/main.js

open instrumentscli0.trace

