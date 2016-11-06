ROOT=`pwd`
pushd `npm root -g`
remark -u remark-slug -u remark-validate-links "${ROOT}/*.md"
remark -u remark-slug -u remark-validate-links "${ROOT}/**/*.md"
popd
