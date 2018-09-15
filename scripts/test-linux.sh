set -e

function cleanup {
	git checkout Package.swift
}

if [[ `uname` == "Darwin" ]]; then
	if [[ `git diff HEAD Package.swift | wc -l` > 0 ]]; then
		echo "Package.swift has uncommitted changes"
		exit -1
	fi
	trap cleanup EXIT
	echo "Running linux"
	eval $(docker-machine env default)
	docker exec -it swift bash -c "cd /projects/RxSwift; scripts/test-linux.sh"
elif [[ `uname` == "Linux" ]]; then
	CONFIGURATIONS=(debug release)

	rm -rf .build || true

	./scripts/all-tests.sh Unix

	git checkout Package.swift

	for configuration in ${CONFIGURATIONS[@]}
	do
		swift build -c ${configuration}
	done
else
	echo "Unknown os (`uname`)"
	exit -1
fi
