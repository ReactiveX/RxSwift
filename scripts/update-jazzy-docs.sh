. scripts/common.sh

function updateDocs() {
  WORKSPACE=$1
  SCHEME=$2
  CONFIGURATION=$3
  SIMULATOR=$4
  MODULE=$5

  # ensure_simulator_available "${SIMULATOR}"
  SIMULATOR_GUID="B20E615F-E3A6-477B-A7A4-8C8541D0E06A"
  DESTINATION='id='$SIMULATOR_GUID''

  set -x
  killall Simulator || true
  jazzy --config .jazzy.yml --theme fullwidth --github_url https://github.com/ReactiveX/RxSwift -m "${MODULE}" -x -workspace,"${WORKSPACE}",-scheme,"${SCHEME}",-configuration,"${CONFIGURATION}",-derivedDataPath,"${BUILD_DIRECTORY}",-destination,"$DESTINATION",CODE_SIGN_IDENTITY=,CODE_SIGNING_REQUIRED=NO,CODE_SIGNING_ALLOWED=NO
  set +x
}

./scripts/update-jazzy-config.rb

updateDocs Rx.xcworkspace "RxExample-iOS" "Release" "iPhone 16 Pro" "RxSwift"
