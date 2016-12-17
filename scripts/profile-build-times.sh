set -oe pipefail
mkdir -p build
xcodebuild -workspace Rx.xcworkspace -scheme RxSwift-iOS -configuration Debug -destination "name=iPhone 7" clean test OTHER_SWIFT_FLAGS="-Xfrontend -debug-time-function-bodies" \
  | tee build/output \
  | grep .[0-9]ms \
  | grep -v ^0.[0-9]ms \
  | sort -nr > build/build-times.txt \
	&& cat build/build-times.txt | less
