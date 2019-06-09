. scripts/common.sh

function updateDocs() {
  WORKSPACE=$1
  SCHEME=$2
  CONFIGURATION=$3
  SIMULATOR=$4
  MODULE=$5

  ensure_simulator_available "${SIMULATOR}"
  SIMULATOR_GUID=`simulator_ids "${SIMULATOR}"`
  DESTINATION='id='$SIMULATOR_GUID''

  set -x
  killall Simulator || true
  jazzy --theme fullwidth \
        --github_url https://github.com/ReactiveX/RxSwift \
        --output Documentation/API \
        --config .jazzy.yml \
        -m "${MODULE}" -x -workspace,"${WORKSPACE}",-scheme,"${SCHEME}",-configuration,"${CONFIGURATION}",-derivedDataPath,"${BUILD_DIRECTORY}",-destination,"$DESTINATION" \
  set +x
}

./scripts/update-jazzy-config.rb

updateDocs Rx.xcworkspace "RxExample-iOS" "Release" $DEFAULT_IOS_SIMULATOR "RxSwift"

if [[ "${TRAVIS}" == "1" ]]; then
	ensureNoGitChanges "API docs aren't updated. please run ./scripts/update-jazzy-docs.sh and commit the changes" "Documentation/API/search.json"
fi