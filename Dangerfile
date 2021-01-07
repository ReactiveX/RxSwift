# Warn about develop branch
warn("Please target PRs to `develop` branch") if github.branch_for_base != "develop"

# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn no CHANGELOG
warn("No CHANGELOG changes made") if git.lines_of_code > 50 && !git.modified_files.include?("CHANGELOG.md") && !declared_trivial

# Warn pod spec changes
warn("RxCocoa.podspec changed") if git.modified_files.include?("RxCocoa.podspec")
warn("RxSwift.podspec changed") if git.modified_files.include?("RxSwift.podspec")
warn("RxTest.podspec changed") if git.modified_files.include?("RxTest.podspec")
warn("RxBlocking.podspec changed") if git.modified_files.include?("RxBlocking.podspec")

# Warn summary on pull request
if github.pr_body.length < 5
  warn "Please provide a summary in the Pull Request description"
end

# If these are all empty something has gone wrong, better to raise it in a comment
if git.modified_files.empty? && git.added_files.empty? && git.deleted_files.empty?
  fail "This PR has no changes at all, this is likely a developer issue."
end

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500
