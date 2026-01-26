. scripts/common.sh

VERSION=$(grep 'RX_VERSION' Version.xcconfig | cut -d'=' -f2 | tr -d ' ')

function updateDocs() {
  WORKSPACE=$1
  SCHEME=$2
  CONFIGURATION=$3
  SIMULATOR=$4
  MODULE=$5

  SIMULATOR_GUID=$(xcrun simctl list devices available | grep "$SIMULATOR" | head -1 | grep -oE '[A-F0-9-]{36}')
  DESTINATION='id='$SIMULATOR_GUID''

  set -x
  killall Simulator || true
  jazzy --config .jazzy.yml --module-version "${VERSION}" --theme fullwidth --github_url https://github.com/ReactiveX/RxSwift -m "${MODULE}" -x -workspace,"${WORKSPACE}",-scheme,"${SCHEME}",-configuration,"${CONFIGURATION}",-derivedDataPath,"${BUILD_DIRECTORY}",-destination,"$DESTINATION",CODE_SIGN_IDENTITY=,CODE_SIGNING_REQUIRED=NO,CODE_SIGNING_ALLOWED=NO
  set +x
}

./scripts/update-jazzy-config.rb

updateDocs Rx.xcworkspace "RxExample-iOS" "Release" "iPhone 17 Pro" "RxSwift"
