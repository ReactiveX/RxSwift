set -ex

if [[ ! -z "${TRAVIS}" ]]; then
    gem install cocoapods --pre --no-document --quiet
    pod --version
fi;

TARGETS=(RxTest RxCocoa RxRelay RxBlocking RxSwift)

function validate() {
    local PODSPEC=$1

    if [ $PODSPEC = "RxCocoa" ]; then
      pod lib lint $PODSPEC --verbose --no-clean --allow-warnings --include-podspecs='*.podspec'
    else
      pod lib lint $PODSPEC --verbose --no-clean --include-podspecs='*.podspec'
    fi
}

for TARGET_ITERATOR in ${TARGETS[@]}
do
    if [[ "${TARGET}" != "" ]] && [[ "${TARGET}" != "${TARGET_ITERATOR}" ]]
    then
        continue
    fi

    validate ${TARGET_ITERATOR}.podspec
done