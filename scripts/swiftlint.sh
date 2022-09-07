if [[ "${TRAVIS}" != "" ]] || [[ "${LINT}" != "" ]]; then
    if which swiftlint >/dev/null; then
        swiftlint
    else
        echo "warning: SwiftLint is not installed"
    fi
else
    echo "To run swiftlint please set TRAVIS or LINT environmental variable."
fi
