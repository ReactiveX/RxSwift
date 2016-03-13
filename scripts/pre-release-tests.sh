. scripts/common.sh

TV_OS=0
RELEASE_TEST=0

if [ `xcodebuild -showsdks | grep tvOS | wc -l` -gt 0 ]; then
	printf "${GREEN}tvOS found${RESET}\n"
	TV_OS=1
fi

if [ "$1" == "r" ]; then
	printf "${GREEN}Pre release tests on, hang on tight ...${RESET}\n"
	RELEASE_TEST=1
fi

./scripts/validate-headers.swift
./scripts/package-spm.swift > /dev/null

if [ `git ls-files -o -d --exclude-standard | wc -l` -gt 0 ]; then
	echo "Package for Swift package manager isn't updated, please run ./scripts/package-spm.swift and commit the changes"
	exit -1
fi

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

CONFIGURATIONS=(Release-Tests)

if [ "${RELEASE_TEST}" -eq 1 ]; then
	CONFIGURATIONS=(Release Release-Tests Debug)
fi

if [ "${RELEASE_TEST}" -eq 1 ]; then
  scripts/validate-markdown.sh
	scripts/validate-podspec.sh
fi

if [ "${RELEASE_TEST}" -eq 1 ]; then
	. scripts/automation-tests.sh
fi

# make sure no module can be built
for scheme in "RxExample-iOS-no-module"
do
	for configuration in ${CONFIGURATIONS[@]}
	do
		rx ${scheme} ${configuration} $DEFAULT_IOS9_SIMULATOR build
	done
done

#make sure all tvOS tests pass
if [ $TV_OS -eq 1 ]; then
	for configuration in ${CONFIGURATIONS[@]}
	do
		rx "RxSwift-tvOS" ${configuration} $DEFAULT_TVOS_SIMULATOR test
	done
fi

# make sure watchos builds
# temporary solution
WATCH_OS_BUILD_TARGETS=(RxSwift-watchOS RxCocoa-watchOS RxBlocking-watchOS)
for scheme in ${WATCH_OS_BUILD_TARGETS[@]}
do
	for configuration in ${CONFIGURATIONS[@]}
	do
		rx "${scheme}" "${configuration}" "${DEFAULT_WATCHOS2_SIMULATOR}" build
	done
done

#make sure all iOS tests pass
for configuration in ${CONFIGURATIONS[@]}
do
	rx "RxSwift-iOS" ${configuration} $DEFAULT_IOS9_SIMULATOR test
done

#make sure all watchOS tests pass
#tests for Watch OS are not available rdar://21760513
# for configuration in ${CONFIGURATIONS[@]}
# do
# 	rx "RxTests-watchOS" ${configuration} $DEFAULT_WATCHOS2_SIMULATOR test
# done

#make sure all OSX tests pass
for configuration in ${CONFIGURATIONS[@]}
do
	rx "RxSwift-OSX" ${configuration} "" test
done

# make sure with modules can be built
for scheme in "RxExample-iOS"
do
	for configuration in ${CONFIGURATIONS[@]}
	do
		rx ${scheme} ${configuration} $DEFAULT_IOS9_SIMULATOR build
	done
done

for scheme in "RxExample-iOS"
do
    for configuration in "Debug"
    do
        rx ${scheme} ${configuration} $DEFAULT_IOS9_SIMULATOR test
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

# compile and run playgrounds

. scripts/validate-playgrounds.sh
