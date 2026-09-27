#!/usr/bin/env bash
# Fail closed: any archive/build/sign failure must abort before zipping.
set -euo pipefail

products=(RxSwift RxRelay RxCocoa RxTest RxBlocking)

rm -rf .build
rm -rf "${products[@]/%/.xcframework}"
rm -f ./RxSwift.xcframework.zip
mkdir .build

BUILD_PATH=$(realpath .build)

archive() {
  local project_name=$1
  local archive_suffix=$2
  shift 2
  xcodebuild -workspace Rx.xcworkspace -configuration Release \
    -archivePath "${BUILD_PATH}/${project_name}-${archive_suffix}.xcarchive" \
    SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
    -scheme "$project_name" archive "$@" | xcbeautify
}

create_xcframework() {
  local project_name=$1
  shift
  local args=()
  local suffix
  for suffix in "$@"; do
    args+=(
      -framework "${BUILD_PATH}/${project_name}-${suffix}.xcarchive/Products/Library/Frameworks/${project_name}.framework"
      -debug-symbols "${BUILD_PATH}/${project_name}-${suffix}.xcarchive/dSYMs/${project_name}.framework.dSYM"
    )
  done
  xcodebuild -create-xcframework "${args[@]}" -output "./${project_name}.xcframework" | xcbeautify
}

for product in "${products[@]}"; do
  PROJECT_NAME="$product"

  archive "$PROJECT_NAME" iphoneos -destination "generic/platform=iOS"
  archive "$PROJECT_NAME" iossimulator -destination "generic/platform=iOS Simulator"
  archive "$PROJECT_NAME" macosx -destination "generic/platform=macOS,name=Any Mac"
  archive "$PROJECT_NAME" maccatalyst -destination "generic/platform=macOS,variant=Mac Catalyst"
  archive "$PROJECT_NAME" appletvos -destination "generic/platform=tvOS"
  archive "$PROJECT_NAME" appletvsimulator -destination "generic/platform=tvOS Simulator"
  archive "$PROJECT_NAME" visionos -destination "generic/platform=visionOS"
  archive "$PROJECT_NAME" visionossimulator -destination "generic/platform=visionOS Simulator"

  # RxTest doesn't work on watchOS
  if [[ "$product" != "RxTest" ]]; then
    archive "$PROJECT_NAME" watchos -destination "generic/platform=watchOS"
    archive "$PROJECT_NAME" watchsimulator -destination "generic/platform=watchOS Simulator"
    create_xcframework "$PROJECT_NAME" \
      iphoneos iossimulator macosx maccatalyst \
      watchos watchsimulator appletvos appletvsimulator \
      visionos visionossimulator
  else
    create_xcframework "$PROJECT_NAME" \
      iphoneos iossimulator macosx maccatalyst \
      appletvos appletvsimulator visionos visionossimulator
  fi

  if [[ ! -d "./${PROJECT_NAME}.xcframework" ]]; then
    echo "error: expected ./${PROJECT_NAME}.xcframework was not created" >&2
    exit 1
  fi

  # Code sign the binary
  codesign --timestamp -v --sign "Apple Distribution: Shai Mishali (272EB7D3H3)" "./${PROJECT_NAME}.xcframework"
done

# Zip all frameworks to a single ZIP
# This is (unfortunately) required by Carthage to work: https://bit.ly/3LVm0Y9
zip -r ./RxSwift.xcframework.zip *.xcframework
