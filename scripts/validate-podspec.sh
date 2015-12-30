# This is kind of naughty, I know,
# but we need to know what will the state be once RxSwift is deployed.

set -e

function cleanup {
  pushd ~/.cocoapods/repos/master
  git clean -d -f
  git reset master --hard
  popd
}

trap cleanup EXIT

VERSION=`cat RxSwift.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
TARGETS=(RxTests RxCocoa RxBlocking RxSwift)

pushd ~/.cocoapods/repos/master/Specs
for TARGET in ${TARGETS[@]}
do
  mkdir -p ${TARGET}/${VERSION}
done
popd

BRANCH=develop

for TARGET in ${TARGETS[@]}
do

  mkdir -p ~/.cocoapods/repos/master/Specs/${TARGET}/${VERSION}
  rm       ~/.cocoapods/repos/master/Specs/${TARGET}/${VERSION}/* || echo

  cat $TARGET.podspec |
  sed -E "s/s.source[^\}]+\}/s.source           = { :git => '\/Users\/kzaher\/Projects\/RxSwift', :branch => \'${BRANCH}\' }/" > ~/.cocoapods/repos/master/Specs/${TARGET}/${VERSION}/${TARGET}.podspec
done

function validate() {
    local PODSPEC=$1

    pod lib lint $PODSPEC --verbose --no-clean
}

for TARGET in ${TARGETS[@]}
do

validate ${TARGET}.podspec

done
