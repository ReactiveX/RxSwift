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

function ensureVersionEqual() {
	if [[ "$1" != "$2" ]]; then
		echo "Version $1 and $2 are not equal ($3)"
		exit -1
	fi 
}

function ensureNoGitChanges() {
	if [ `git diff HEAD | wc -l` -gt 0 ]; then
		echo $1
		exit -1
	fi
}

function checkPlistVersions() {
	RXSWIFT_VERSION=`cat RxSwift.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
	
	PROJECTS=(RxSwift RxCocoa RxBlocking RxTests)
	for project in ${PROJECTS[@]}
	do
		echo "Checking version for ${project}"
		PODSPEC_VERSION=`cat $project.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
		ensureVersionEqual "$RXSWIFT_VERSION" "$PODSPEC_VERSION" "${project} version not equal"
		if [[ `defaults write  "\`pwd\`/${project}/Info.plist" CFBundleShortVersionString $RXSWIFT_VERSION` != $RXSWIFT_VERSION ]]; then
			defaults write  "`pwd`/${project}/Info.plist" CFBundleShortVersionString $RXSWIFT_VERSION
		fi
	done

	ensureNoGitChanges "Plist versions aren't correct"
}

checkPlistVersions

if [ "${IS_SWIFT_3}" -ne 1 ]; then
    ./scripts/validate-headers.swift
    ./scripts/package-spm.swift > /dev/null
fi
ensureNoGitChanges "Package for Swift package manager isn't updated, please run ./scripts/package-spm.swift and commit the changes"

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
		rx "${scheme}" "${configuration}" "${DEFAULT_WATCHOS_SIMULATOR}" build
	done
done

#make sure all iOS tests pass
for configuration in ${CONFIGURATIONS[@]}
do
	rx "RxSwift-iOS" ${configuration} $DEFAULT_IOS_SIMULATOR test
done

#make sure all watchOS tests pass
#tests for Watch OS are not available rdar://21760513
# for configuration in ${CONFIGURATIONS[@]}
# do
# 	rx "RxTests-watchOS" ${configuration} $DEFAULT_WATCHOS_SIMULATOR test
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
		rx ${scheme} ${configuration} $DEFAULT_IOS_SIMULATOR build
	done
done

for scheme in "RxExample-iOS"
do
    for configuration in "Debug"
    do
        rx ${scheme} ${configuration} $DEFAULT_IOS_SIMULATOR test
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

if [ "${IS_SWIFT_3}" -ne 1 ]; then
	. scripts/validate-playgrounds.sh
fi
