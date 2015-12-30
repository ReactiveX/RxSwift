set -e

CONFIGURATIONS=(debug release)

for configuration in ${CONFIGURATIONS[@]}
do
    swift build -c ${configuration} && .build/${configuration}/AllTests
done

