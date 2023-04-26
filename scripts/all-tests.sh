. scripts/common.sh

RELEASE_TEST=0

VALIDATE_IOS_EXAMPLE=1
VALIDATE_UNIX=1
VALIDATE_IOS=1
VALIDATE_TVOS=1
VALIDATE_WATCHOS=1
TEST_SPM=1

UNIX_NAME=`uname`
DARWIN="Darwin"
LINUX="Linux"

function unsuppported_os() {
	printf "${RED}Unsupported os: ${UNIX_NAME}${RESET}\n"
	exit -1
}

function unsupported_target() {
	printf "${RED}Unsupported os: ${UNIX_NAME}${RESET}\n"
	exit -1
}

if [ "$1" == "r" ]; then
	printf "${GREEN}Pre release tests on, hang on tight ...${RESET}\n"
	RELEASE_TEST=1
elif [ "$1" == "iOS-Example" ]; then
	VALIDATE_IOS_EXAMPLE=1
	VALIDATE_UNIX=0
	VALIDATE_IOS=0
	VALIDATE_TVOS=0
	VALIDATE_WATCHOS=0
	TEST_SPM=0
elif [ "$1" == "Unix" ]; then
	VALIDATE_IOS_EXAMPLE=0
	VALIDATE_UNIX=1
	VALIDATE_IOS=0
	VALIDATE_TVOS=0
	VALIDATE_WATCHOS=0
	TEST_SPM=0
elif [ "$1" == "iOS" ]; then
	VALIDATE_IOS_EXAMPLE=0
	VALIDATE_UNIX=0
	VALIDATE_IOS=1
	VALIDATE_TVOS=0
	VALIDATE_WATCHOS=0
	TEST_SPM=0
elif [ "$1" == "tvOS" ]; then
	VALIDATE_IOS_EXAMPLE=0
	VALIDATE_UNIX=0
	VALIDATE_IOS=0
	VALIDATE_TVOS=1
	VALIDATE_WATCHOS=0
	TEST_SPM=0
elif [ "$1" == "watchOS" ]; then
	VALIDATE_IOS_EXAMPLE=0
	VALIDATE_UNIX=0
	VALIDATE_IOS=0
	VALIDATE_TVOS=0
	VALIDATE_WATCHOS=1
	TEST_SPM=0
elif [ "$1" == "SPM" ]; then
	VALIDATE_IOS_EXAMPLE=0
	VALIDATE_UNIX=0
	VALIDATE_IOS=0
	VALIDATE_TVOS=0
	VALIDATE_WATCHOS=0
	TEST_SPM=1
fi

if [ "${RELEASE_TEST}" -eq 1 ]; then
	VALIDATE_PODS=${VALIDATE_PODS:-1}
else
	VALIDATE_PODS=${VALIDATE_PODS:-0}
fi

RUN_DEVICE_TESTS=${RUN_DEVICE_TESTS:-1}

function ensureVersionEqual() {
	if [[ "$1" != "$2" ]]; then
		echo "Version $1 and $2 are not equal ($3)"
		exit -1
	fi 
}

function ensureNoGitChanges() {
	if [ `(git add . && git diff HEAD && git reset) | wc -l` -gt 0 ]; then
		echo $1
		exit -1
	fi
}

function checkPlistVersions() {
	RXSWIFT_VERSION=`cat RxSwift.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
	echo "RxSwift version: ${RXSWIFT_VERSION}"
	PROJECTS=(RxSwift RxCocoa RxRelay RxBlocking RxTest)
	for project in ${PROJECTS[@]}
	do
		echo "Checking version for ${project}"
		PODSPEC_VERSION=`cat $project.podspec | grep -E "s.version\s+=" | cut -d '"' -f 2`
		ensureVersionEqual "$RXSWIFT_VERSION" "$PODSPEC_VERSION" "${project} version not equal"
		PLIST_VERSION=`defaults read  "\`pwd\`/${project}/Info.plist" CFBundleShortVersionString`
		if ! ( [[ ${RXSWIFT_VERSION} = *"-"* ]] || [[ "${PLIST_VERSION}" == "${RXSWIFT_VERSION}" ]] ) ; then
			echo "Invalid version for `pwd`/${project}/Info.plist: ${PLIST_VERSION}"
          	exit -1
		fi
	done
}

ensureNoGitChanges "Please make sure the working tree is clean. Use \`git status\` to check."
if [[ "${UNIX_NAME}" == "${DARWIN}" ]]; then
	checkPlistVersions

	./scripts/update-jazzy-config.rb

	ensureNoGitChanges "Please run ./scripts/update-jazzy-config.rb"

	./scripts/validate-headers.swift
	./scripts/package-spm.swift > /dev/null

	ensureNoGitChanges "Package for Swift package manager isn't updated, please run ./scripts/package-spm.swift and commit the changes"
fi

CONFIGURATIONS=(Debug)

if [ "${RELEASE_TEST}" -eq 1 ]; then
	CONFIGURATIONS=(Debug Release Release-Tests)
fi

if [ "${VALIDATE_PODS}" -eq 1 ]; then
	SWIFT_VERSION=5.0 scripts/validate-podspec.sh
fi

if [ "${VALIDATE_IOS_EXAMPLE}" -eq 1 ]; then
	if [[ "${UNIX_NAME}" == "${DARWIN}" ]]; then
		for scheme in "RxExample-iOS"
		do
			for configuration in "Debug"
			do
				rx ${scheme} ${configuration} "${DEFAULT_IOS_SIMULATOR}" build
			done
		done
	elif [[ "${UNIX_NAME}" == "${LINUX}" ]]; then
		unsupported_target
	else
		unsupported_os
	fi
else
	printf "${RED}Skipping iOS-Example tests ...${RESET}\n"
fi

if [ "${VALIDATE_IOS}" -eq 1 ]; then
	if [[ "${UNIX_NAME}" == "${DARWIN}" ]]; then
		#make sure all iOS tests pass
		for configuration in ${CONFIGURATIONS[@]}
		do
			rx "AllTests-iOS" ${configuration} "${DEFAULT_IOS_SIMULATOR}" test
		done
	elif [[ "${UNIX_NAME}" == "${LINUX}" ]]; then
		unsupported_target
	else
		unsupported_os
	fi
else
	printf "${RED}Skipping iOS tests ...${RESET}\n"
fi


if [ "${VALIDATE_UNIX}" -eq 1 ]; then
	if [[ "${UNIX_NAME}" == "${DARWIN}" ]]; then
		if [[ "${CI}" == "" ]]; then
			./scripts/test-linux.sh
		fi

		# compile and run playgrounds
		. scripts/validate-playgrounds.sh

		# make sure macOS builds
		for scheme in "RxExample-macOS"
		do
			for configuration in ${CONFIGURATIONS[@]}
			do
				rx ${scheme} ${configuration} "" build
			done
		done

		#make sure all macOS tests pass
		for configuration in ${CONFIGURATIONS[@]}
		do
			rx "AllTests-macOS" ${configuration} "" test
		done
	elif [[ "${UNIX_NAME}" == "${LINUX}" ]]; then
		CONFIGURATIONS=(debug release)
		for configuration in ${CONFIGURATIONS[@]}
		do
			echo "Linux Configuration ${configuration}"
			git checkout Package.swift
			if [[ $configuration == "debug" ]]; then
				cat Package.swift | sed "s/let buildTests = false/let buildTests = true/" > Package.tests.swift
				mv Package.tests.swift Package.swift
			fi
			swift build -c ${configuration}
			if [[ $configuration == "debug" ]]; then
				./.build/debug/AllTestz
			fi
		done
	else
		unsupported_os
	fi
else
	printf "${RED}Skipping Unix (macOS, Linux) tests ...${RESET}\n"
fi

if [ "${VALIDATE_TVOS}" -eq 1 ]; then
	if [[ "${UNIX_NAME}" == "${DARWIN}" ]]; then
		for configuration in ${CONFIGURATIONS[@]}
		do
			rx "AllTests-tvOS" ${configuration} "${DEFAULT_TVOS_SIMULATOR}" test
		done
	elif [[ "${UNIX_NAME}" == "${LINUX}" ]]; then
		printf "${RED}Skipping tvOS tests ...${RESET}\n"
	else
		unsupported_os
	fi
else
	printf "${RED}Skipping tvOS tests ...${RESET}\n"
fi

if [ "${VALIDATE_WATCHOS}" -eq 1 ]; then
	if [[ "${UNIX_NAME}" == "${DARWIN}" ]]; then
		# make sure watchos builds
		# temporary solution
		WATCH_OS_BUILD_TARGETS=(RxSwift RxCocoa RxRelay RxBlocking)
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
	elif [[ "${UNIX_NAME}" == "${LINUX}" ]]; then
		printf "${RED}Skipping watchOS tests ...${RESET}\n"
	else
		unsupported_os
	fi
else
	printf "${RED}Skipping watchOS tests ...${RESET}\n"
fi

if [ "${TEST_SPM}" -eq 1 ]; then
	rm -rf .build || true
	swift build -c release --disable-sandbox # until compiler is fixed
	swift build -c debug --disable-sandbox # until compiler is fixed
else
	printf "${RED}Skipping SPM tests ...${RESET}\n"
fi
