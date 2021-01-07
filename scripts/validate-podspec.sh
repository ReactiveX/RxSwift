#!/bin/sh

set -e

# EXTRA_FLAGS="--include-podspecs='RxSwift.podspec'"

case $TARGET in
"RxSwift"*)
    pod lib lint --verbose --no-clean --swift-version=$SWIFT_VERSION --allow-warnings RxSwift.podspec
    ;;
"RxCocoa"*)
    pod lib lint --verbose --no-clean --swift-version=$SWIFT_VERSION --allow-warnings --include-podspecs='{RxSwift, RxRelay}.podspec' RxCocoa.podspec
    ;;
"RxRelay"*)
    pod lib lint --verbose --no-clean --swift-version=$SWIFT_VERSION --allow-warnings --include-podspecs='RxSwift.podspec' RxRelay.podspec
    ;;
"RxBlocking"*)
    pod lib lint --verbose --no-clean --swift-version=$SWIFT_VERSION --allow-warnings --include-podspecs='RxSwift.podspec' RxBlocking.podspec
    ;;
"RxTest"*)
    pod lib lint --verbose --no-clean --swift-version=$SWIFT_VERSION --allow-warnings --include-podspecs='RxSwift.podspec' RxTest.podspec
    ;;
esac

# Not sure why this isn't working ¯\_(ツ)_/¯, will figure it out some other time
# pod lib lint --verbose --no-clean --swift-version=${SWIFT_VERSION} ${EXTRA_FLAGS} ${TARGET}.podspec