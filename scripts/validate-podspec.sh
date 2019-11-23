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
    bundle install
    COCOAPODS_REPO_COUNT=`bundle exec pod repo list --count-only | cut -c 1`

    if [[ $COCOAPODS_REPO_COUNT == "0" ]]; then
        # No repo spec yet, we have to set it up
        bundle exec pod setup
    else
        # We have some remote repo (cached or otherwise), so we can simply update it 
        bundle exec pod repo update
    fi
fi

VERSION=`cat RxSwift.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
ROOTS=(8/5/5 3/c/1 9/2/4 a/b/1 2/e/c)
TARGETS=(RxTest RxCocoa RxRelay RxBlocking RxSwift)

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

    validate=(pod lib lint $PODSPEC --verbose --no-clean ${arg} "${SWIFT_VERSION}")
    if [ $TARGET = "RxCocoa" ]; then
      validate+=(--allow-warnings)
    fi
    echo "${validate[@]}"
}

for TARGET_ITERATOR in ${TARGETS[@]}
do
    if [[ "${TARGET}" != "" ]] && [[ "${TARGET}" != "${TARGET_ITERATOR}" ]]
    then
        continue
    fi

    validate ${TARGET_ITERATOR}.podspec
done
