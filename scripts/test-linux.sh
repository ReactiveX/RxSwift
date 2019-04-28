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
	docker run --rm  -it -v `pwd`:/RxSwift swift:rxswift-linux-5.0.1 bash -c "cd /RxSwift; scripts/test-linux.sh" || (echo "You maybe need to create a docker image: 'docker build -t swift:rxswift-linux-5.0.1 scripts' to create docker container" && exit -1)
elif [[ `uname` == "Linux" ]]; then
	CONFIGURATIONS=(debug release)

	rm -rf .build || true

	echo "Using `swift -version`"

	./scripts/all-tests.sh Unix
else
	echo "Unknown os (`uname`)"
	exit -1
fi
