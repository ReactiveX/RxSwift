ROOT=`pwd`
pushd `npm root -g`
remark -u remark-slug -u remark-validate-links "${ROOT}/*.md" "${ROOT}/**/*.md" "${ROOT}/.github/ISSUE_TEMPLATE.md" "${ROOT}/RxExample/" "${ROOT}/RxCocoa/Foundation/KVORepresentable+CoreGraphics.swift" "${ROOT}/Rx.playground"
popd
