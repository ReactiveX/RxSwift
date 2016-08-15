# Warn about develop branch
current_branch = env.request_source.pr_json["base"]["ref"]
warn("Please target PRs to `develop` branch") if current_branch != "develop" && current_branch != "swift-3.0"

# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if pr_title.include? "[WIP]"

# Warn no CHANGELOG
warn("No CHANGELOG changes made") if lines_of_code > 50 && !modified_files.include?("CHANGELOG.yml") && !declared_trivial

# Warn pod spec changes
warn("RxCocoa.podspec changed") if modified_files.include?("RxCocoa.podspec")
warn("RxSwift.podspec changed") if modified_files.include?("RxSwift.podspec")
warn("RxTests.podspec changed") if modified_files.include?("RxTests.podspec")
warn("RxBlocking.podspec changed") if modified_files.include?("RxBlocking.podspec")

# Warn summary on pull request
if pr_body.length < 5
  warn "Please provide a summary in the Pull Request description"
end

# If these are all empty something has gone wrong, better to raise it in a comment
if modified_files.empty? && added_files.empty? && deleted_files.empty?
  fail "This PR has no changes at all, this is likely a developer issue."
end

# Warn when there is a big PR
warn("Big PR") if lines_of_code > 500

