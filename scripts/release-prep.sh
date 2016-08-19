. scripts/common.sh

# run tests
. scripts/pre-release-tests.sh

# update jazzy documentation config
printf "${GREEN}Updating .jazzy.yml${RESET}\n"
./scripts/update-jazzy-config.rb
exitIfLastStatusWasUnsuccessful
printf "${GREEN}Successfully updated .jazzy.yml${RESET}\n"
