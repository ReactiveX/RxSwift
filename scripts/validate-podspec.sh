# This is kind of naughty, I know,
# but we need to know what will the state be once RxSwift is deployed.

set -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)
ESCAPED_SOURCE=$(pwd | sed -E "s/\//\\\\\//g")

function cleanup {
  pushd ~/.cocoapods/repos/master
  git clean -d -f
  git reset master --hard
  popd
}

trap cleanup EXIT

VERSION=`cat RxSwift.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
TARGETS=(RxTest RxCocoa RxBlocking RxAtomic RxSwift)
ROOTS=(2/e/c 3/c/1 8/5/5 f/7/9 a/b/1)

pushd ~/.cocoapods/repos/master/Specs
for TARGET in ${TARGETS[@]}
do
  mkdir -p ${TARGET}/${VERSION}
done
popd

for TARGET in ${TARGETS[@]}
do


    for ROOT in ${ROOTS[@]} ; do
        mkdir -p ~/.cocoapods/repos/master/Specs/${ROOT}/${TARGET}/${VERSION}
        rm       ~/.cocoapods/repos/master/Specs/${ROOT}/${TARGET}/${VERSION}/* || echo
        cat $TARGET.podspec |
        sed -E "s/s.source [^\}]+\}/s.source           = { :git => '${ESCAPED_SOURCE}', :branch => \'${BRANCH}\' }/" > ~/.cocoapods/repos/master/Specs/${ROOT}/${TARGET}/${VERSION}/${TARGET}.podspec
    done

done

function validate() {
    local PODSPEC=$1

    pod lib lint $PODSPEC --verbose --no-clean --allow-warnings
}

for TARGET in ${TARGETS[@]}
do

validate ${TARGET}.podspec

done
