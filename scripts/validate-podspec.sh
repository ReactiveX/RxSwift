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

popd
popd

cat RxSwift.podspec |
sed -E "s/s.source[^\}]+\}/s.source           = { :git => '\/Users\/kzaher\/Projects\/Rx', :branch => \'develop\' }/" > ~/.cocoapods/repos/master/Specs/RxSwift/${VERSION}/RxSwift.podspec

cat RxCocoa.podspec |
sed -E "s/s.source[^\}]+\}/s.source           = { :git => '\/Users\/kzaher\/Projects\/Rx', :branch => \'develop\' }/" > ~/.cocoapods/repos/master/Specs/RxCocoa/${VERSION}/RxCocoa.podspec

cat RxBlocking.podspec |
sed -E "s/s.source[^\}]+\}/s.source           = { :git => '\/Users\/kzaher\/Projects\/Rx', :branch => \'develop\' }/" > ~/.cocoapods/repos/master/Specs/RxBlocking/${VERSION}/RxBlocking.podspec

pod lib lint RxSwift.podspec
pod lib lint RxCocoa.podspec
pod lib lint RxBlocking.podspec
