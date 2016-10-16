#!/usr/bin/env ruby

require 'yaml'

included_directories = %w(RxSwift RxCocoa)

files_and_directories = included_directories.collect do |directory|
  Dir.glob("#{directory}/**/*")
end.flatten

swift_files = files_and_directories.select { |file| file =~ /.*\.swift$/ }

directory_and_name = swift_files.map do |file|
  { File.dirname(file) => File.basename(file, '.swift') }
end

categories = directory_and_name.flat_map(&:entries)
  .group_by(&:first)
  .map { |k,v| { 'name' => k, 'children' => v.map(&:last) } }

config = { 'custom_categories' => categories }

File.open('.jazzy.yml','w') do |h|
   h.write config.to_yaml
end
