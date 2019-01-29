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
ALL_TARGETS=(RxTest RxCocoa RxBlocking RxAtomic RxSwift)

if [ ! -z "$TARGET" ]
then
    TARGETS=("$TARGET")
else
    TARGETS="${ALL_TARGETS}"
fi

if [ ! -z "$SWIFT_VERSION" ]
then
    SWIFT_VERSION="--swift-version=${SWIFT_VERSION}"
fi

SOURCE_DIR=`pwd`

pushd ~/.cocoapods/repos/master/Specs
    for ROOT in ${ROOTS[@]} ; do
        for TARGET in ${ALL_TARGETS[@]}
        do
            if [ ! -d "${ROOT}/${TARGET}" ]
            then
                continue
            fi

            mkdir -p ${ROOT}/${TARGET}/${VERSION}
            rm ${ROOT}/${TARGET}/${VERSION}/* || echo
            cat "${SOURCE_DIR}/$TARGET.podspec" |
            sed -E "s/s.source [^\}]+\}/s.source           = { :git => 'file:\/\/${ESCAPED_SOURCE}' }/" > ${ROOT}/${TARGET}/${VERSION}/${TARGET}.podspec
        done
    done
popd

function validate() {
    local PODSPEC=$1

    pod lib lint $PODSPEC --verbose --no-clean --allow-warnings "${SWIFT_VERSION}"
}

for TARGET in ${TARGETS[@]}
do
    validate ${TARGET}.podspec
done
