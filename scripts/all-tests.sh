. scripts/common.sh

RELEASE_TEST=0
SKIP_AUTOMATION=0

VALIDATE_IOS_EXAMPLE=1
VALIDATE_OSX=1
VALIDATE_IOS=1
VALIDATE_TVOS=1
VALIDATE_WATCHOS=1

if [ "$1" == "r" ]; then
	printf "${GREEN}Pre release tests on, hang on tight ...${RESET}\n"
	RELEASE_TEST=1
elif [ "$1" == "iOS-Example" ]; then
    VALIDATE_IOS_EXAMPLE=1
    VALIDATE_OSX=0
    VALIDATE_IOS=0
    VALIDATE_TVOS=0
    VALIDATE_WATCHOS=0
elif [ "$1" == "OSX" ]; then
    VALIDATE_IOS_EXAMPLE=0
    VALIDATE_OSX=1
    VALIDATE_IOS=0
    VALIDATE_TVOS=0
    VALIDATE_WATCHOS=0
elif [ "$1" == "iOS" ]; then
    VALIDATE_IOS_EXAMPLE=0
    VALIDATE_OSX=0
    VALIDATE_IOS=1
    VALIDATE_TVOS=0
    VALIDATE_WATCHOS=0
elif [ "$1" == "tvOS" ]; then
    VALIDATE_IOS_EXAMPLE=0
    VALIDATE_OSX=0
    VALIDATE_IOS=0
    VALIDATE_TVOS=1
    VALIDATE_WATCHOS=0
elif [ "$1" == "watchOS" ]; then
    VALIDATE_IOS_EXAMPLE=0
    VALIDATE_OSX=0
    VALIDATE_IOS=0
    VALIDATE_TVOS=0
    VALIDATE_WATCHOS=1
fi

if [ "$2" == "s" ]; then
    printf "${RED}Skipping automation tests ...${RESET}\n"
    SKIP_AUTOMATION=1
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
	echo "RxSwift version: ${RXSWIFT_VERSION}"
	PROJECTS=(RxSwift RxCocoa RxBlocking RxTests)
	for project in ${PROJECTS[@]}
	do
		echo "Checking version for ${project}"
		PODSPEC_VERSION=`cat $project.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
		ensureVersionEqual "$RXSWIFT_VERSION" "$PODSPEC_VERSION" "${project} version not equal"
        PLIST_VERSION=`defaults read  "\`pwd\`/${project}/Info.plist" CFBundleShortVersionString`
        if [[ "${PLIST_VERSION}" != "${RXSWIFT_VERSION}" ]]; then
            echo "Invalid version for `pwd`/${project}/Info.plist: ${PLIST_VERSION}"
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
fi

if [ "${RELEASE_TEST}" -eq 1 ]; then
	scripts/validate-podspec.sh
fi

if [ "${VALIDATE_IOS_EXAMPLE}" -eq 1 ]; then
    if [ "${RELEASE_TEST}" -eq 1 ] && [ "${SKIP_AUTOMATION}" -eq 0 ]; then
        for configuration in ${CONFIGURATIONS[@]}
        do
            rx "RxExample-iOSUITests" ${configuration} "Krunoslav Zaher’s iPhone" test
        done

        for configuration in ${CONFIGURATIONS[@]}
        do
            rx "RxExample-iOSUITests" ${configuration} $DEFAULT_IOS_SIMULATOR test
        done
    else
        for scheme in "RxExample-iOS"
        do
            for configuration in "Debug"
            do
                rx ${scheme} ${configuration} $DEFAULT_IOS_SIMULATOR build
            done
        done
    fi
else
    printf "${RED}Skipping iOS-Example tests ...${RESET}\n"
fi

if [ "${VALIDATE_IOS}" -eq 1 ]; then
    #make sure all iOS tests pass
    for configuration in ${CONFIGURATIONS[@]}
    do
    	rx "RxSwift-iOS" ${configuration} $DEFAULT_IOS_SIMULATOR test
    done
else
    printf "${RED}Skipping iOS tests ...${RESET}\n"
fi


if [ "${VALIDATE_OSX}" -eq 1 ]; then
    # compile and run playgrounds
	. scripts/validate-playgrounds.sh

	# make sure osx builds
	for scheme in "RxExample-OSX"
	do
	    for configuration in ${CONFIGURATIONS[@]}
	    do
		rx ${scheme} ${configuration} "" build
	    done
	done

    #make sure all OSX tests pass
    for configuration in ${CONFIGURATIONS[@]}
    do
        rx "RxSwift-OSX" ${configuration} "" test
    done
else
	printf "${RED}Skipping OSX tests ...${RESET}\n"
fi

if [ "${VALIDATE_TVOS}" -eq 1 ]; then
	for configuration in ${CONFIGURATIONS[@]}
	do
		rx "RxSwift-tvOS" ${configuration} $DEFAULT_TVOS_SIMULATOR test
	done
else
    printf "${RED}Skipping tvOS tests ...${RESET}\n"
fi

if [ "${VALIDATE_WATCHOS}" -eq 1 ]; then
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
    #make sure all watchOS tests pass
    #tests for Watch OS are not available rdar://21760513
    # for configuration in ${CONFIGURATIONS[@]}
    # do
    # 	rx "RxTests-watchOS" ${configuration} $DEFAULT_WATCHOS_SIMULATOR test
    # done
else
    printf "${RED}Skipping watchOS tests ...${RESET}\n"
fi

