. scripts/common.sh

CONFIGURATIONS=(Release)

# make sure osx builds
for scheme in "RxSwift-OSX"
do
  for configuration in ${CONFIGURATIONS[@]}
  do
    PAGES_PATH=${BUILD_DIRECTORY}/Build/Products/${configuration}/all-playground-pages.swift
    rx ${scheme} ${configuration} "" build
    cat Rx.playground/Sources/*.swift Rx.playground/Pages/**/*.swift > ${PAGES_PATH}
    swift -v -D NOT_IN_PLAYGROUND -F ${BUILD_DIRECTORY}/Build/Products/${configuration} ${PAGES_PATH}
  done
done

