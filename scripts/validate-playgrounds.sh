. scripts/common.sh

PLAYGROUND_CONFIGURATIONS=(Release)

# make sure macOS builds
for configuration in ${PLAYGROUND_CONFIGURATIONS[@]}
do
  for scheme in "RxSwift RxPlaygrounds"
  do
    rx ${scheme} ${configuration} "" build
  done

  PAGES_PATH=${BUILD_DIRECTORY}/Build/Products/${configuration}/all-playground-pages.swift
  cat Rx.playground/Sources/*.swift Rx.playground/Pages/**/*.swift > ${PAGES_PATH}
  swiftc -v -D NOT_IN_PLAYGROUND -target x86_64-apple-macosx10.10 -F ${BUILD_DIRECTORY}/Build/Products/${configuration} -framework RxSwift ${PAGES_PATH}   
  ./all-playground-pages
done