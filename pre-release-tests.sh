. scripts/common.sh

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
for scheme in "RxExample-iOS" "RxExample-OSX"
do
	for configuration in "Debug" "Release-Tests" "Release"
	do
		buildExample ${scheme} ${configuration}
	done
done

./automation-tests.sh
