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

pushd ~/.cocoapods/repos/master
pushd Specs

mkdir -p RxSwift/${VERSION}
mkdir -p RxCocoa/${VERSION}
mkdir -p RxBlocking/${VERSION}
mkdir -p RxTests/${VERSION}

popd
popd

#BRANCH=develop
BRANCH=feature\\/RxTests

cat RxSwift.podspec |
sed -E "s/s.source[^\}]+\}/s.source           = { :git => '\/Users\/kzaher\/Projects\/Rx', :branch => \'${BRANCH}\' }/" > ~/.cocoapods/repos/master/Specs/RxSwift/${VERSION}/RxSwift.podspec

cat RxCocoa.podspec |
sed -E "s/s.source[^\}]+\}/s.source           = { :git => '\/Users\/kzaher\/Projects\/Rx', :branch => \'${BRANCH}\' }/" > ~/.cocoapods/repos/master/Specs/RxCocoa/${VERSION}/RxCocoa.podspec

cat RxBlocking.podspec |
sed -E "s/s.source[^\}]+\}/s.source           = { :git => '\/Users\/kzaher\/Projects\/Rx', :branch => \'${BRANCH}\' }/" > ~/.cocoapods/repos/master/Specs/RxBlocking/${VERSION}/RxBlocking.podspec

cat RxTests.podspec |
sed -E "s/s.source[^\}]+\}/s.source           = { :git => '\/Users\/kzaher\/Projects\/Rx', :branch => \'${BRANCH}\' }/" > ~/.cocoapods/repos/master/Specs/RxTests/${VERSION}/RxTests.podspec

function validate() {
    local PODSPEC=$1

    pod lib lint $PODSPEC --verbose --no-clean
}

validate RxTests.podspec
validate RxCocoa.podspec
validate RxBlocking.podspec
validate RxSwift.podspec