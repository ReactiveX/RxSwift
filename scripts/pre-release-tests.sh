
IS_LOCAL=0
IS_QUICK=1
if [ "$1" == "l" ]; then
	echo "Local test"
	IS_LOCAL=1
fi

if [ "$1" == "f" ]; then
	echo "Full"
	IS_QUICK=0
else
	echo "Quick"
fi

ISLOCAL="${IS_LOCAL}" . scripts/common.sh

# ios 7 sim
#if [ `xcrun simctl list | grep "${DEFAULT_IOS7_SIMULATOR}" | wc -l` == 0 ]; then
#	xcrun simctl create $DEFAULT_IOS7_SIMULATOR 'iPhone 4s' 'com.apple.CoreSimulator.SimRuntime.iOS-7-1'
#else
#	echo "${DEFAULT_IOS7_SIMULATOR} exists"
#fi

#ios 8 sim
#if [ `xcrun simctl list | grep "${DEFAULT_IOS8_SIMULATOR}" | wc -l` == 0 ]; then
#	xcrun simctl create $DEFAULT_IOS8_SIMULATOR 'iPhone 6' 'com.apple.CoreSimulator.SimRuntime.iOS-8-4'
#else
#	echo "${DEFAULT_IOS8_SIMULATOR} exists"
#fi

if [ "${IS_LOCAL}" -eq 1 ]; then
	. scripts/automation-tests.sh
fi

#ios 9 sim
if [ `xcrun simctl list | grep "${DEFAULT_IOS9_SIMULATOR}" | wc -l` == 0 ]; then
	xcrun simctl create $DEFAULT_IOS9_SIMULATOR 'iPhone 6' 'com.apple.CoreSimulator.SimRuntime.iOS-9-0'
else
	echo "${DEFAULT_IOS9_SIMULATOR} exists"
fi

if [ "${IS_QUICK}" -eq 1 ]; then
	CONFIGURATIONS=(Release)
else
	CONFIGURATIONS=(Debug Release-Tests Release)
fi

#make sure all iOS tests pass
for configuration in ${CONFIGURATIONS[@]}
do
	rx "RxTests-iOS" ${configuration} $DEFAULT_IOS9_SIMULATOR test
done

#make sure all OSX tests pass
for configuration in ${CONFIGURATIONS[@]}
do
	rx "RxTests-OSX" ${configuration} "" test
done

# make sure no module can be built
for scheme in "RxExample-iOS-no-module"
do
	for configuration in ${CONFIGURATIONS[@]}
	do
		#rx ${scheme} ${configuration} $DEFAULT_IOS7_SIMULATOR build
		#rx ${scheme} ${configuration} $DEFAULT_IOS8_SIMULATOR build
		rx ${scheme} ${configuration} $DEFAULT_IOS9_SIMULATOR build
	done
done

# make sure with modules can be built
for scheme in "RxExample-iOS"
do
	for configuration in ${CONFIGURATIONS[@]}
	do
	rx ${scheme} ${configuration} $DEFAULT_IOS9_SIMULATOR build
	done
done

# make sure osx builds
for scheme in "RxExample-OSX"
do
	for configuration in ${CONFIGURATIONS[@]}
	do
		rx ${scheme} ${configuration} "" build
	done
done

if [ "${IS_LOCAL}" -eq 1 ]; then
	mdast -u mdast-slug -u mdast-validate-links ./*.md
	mdast -u mdast-slug -u mdast-validate-links ./**/*.md
fi
