# This is kind of naughty, I know,
# but we need to know what will the state be once RxSwift is deployed.

set -e

BRANCH=$(git rev-parse HEAD)
ESCAPED_SOURCE=$(pwd | sed -E "s/\//\\\\\//g")

function cleanup {
  pushd ~/.cocoapods/repos/master
  git clean -d -f
  git reset master --hard
  popd
}

trap cleanup EXIT

if [[ ! -z "${TRAVIS}" ]]; then
    gem install cocoapods --pre --no-rdoc --no-ri --no-document --quiet;
    pod repo update;
fi;

VERSION=`cat RxSwift.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
ROOTS=(2/e/c 3/c/1 8/5/5 f/7/9 a/b/1)
TARGETS=(RxTest RxCocoa RxBlocking RxAtomic RxSwift)

SWIFT_VERSION="--swift-version=${SWIFT_VERSION}"

SOURCE_DIR=`pwd`

pushd ~/.cocoapods/repos/master/Specs
    for ROOT in ${ROOTS[@]} ; do
        for TARGET_ITERATOR in ${TARGETS[@]}
        do
            if [ ! -d "${ROOT}/${TARGET_ITERATOR}" ]
            then
                continue
            fi

            mkdir -p ${ROOT}/${TARGET_ITERATOR}/${VERSION}
            rm ${ROOT}/${TARGET_ITERATOR}/${VERSION}/* || echo
            cat "${SOURCE_DIR}/$TARGET_ITERATOR.podspec" |
            sed -E "s/s.source [^\}]+\}/s.source           = { :git => 'file:\/\/${ESCAPED_SOURCE}' }/" > ${ROOT}/${TARGET_ITERATOR}/${VERSION}/${TARGET_ITERATOR}.podspec
        done
    done
popd

function validate() {
    local PODSPEC=$1

    pod lib lint $PODSPEC --verbose --no-clean --allow-warnings "${SWIFT_VERSION}"
}

for TARGET_ITERATOR in ${TARGETS[@]}
do
    if [[ "${TARGET}" != "" ]] && [[ "${TARGET}" != "${TARGET_ITERATOR}" ]]
    then
        continue
    fi

    validate ${TARGET_ITERATOR}.podspec
done
