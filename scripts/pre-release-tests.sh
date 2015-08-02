. scripts/common.sh

IS_LOCAL=0
if [ "$#" -eq 1 ]; then
	echo "Local test"
	IS_LOCAL=1
fi

#runTests "RxTests-iOS" "Release-Tests"

#make sure all unit tests pass
for scheme in "RxTests-iOS" "RxTests-OSX"
do
	for configuration in "Debug" "Release-Tests" "Release"
	do
		runTests ${scheme} ${configuration}
	done
done


# make sure it all build
for scheme in "RxExample-iOS" "RxExample-iOS-no-module" "RxExample-OSX"
do
	for configuration in "Debug" "Release-Tests" "Release"
	do
		buildExample ${scheme} ${configuration}
	done
done

if [ "${IS_LOCAL}" -eq 1 ]; then
	. scripts/automation-tests.sh
	mdast -u mdast-slug -u mdast-validate-links ./*.md
	mdast -u mdast-slug -u mdast-validate-links ./**/*.md
fi
