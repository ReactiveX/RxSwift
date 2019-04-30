Pod::Spec.new do |s|
  s.name             = "RxBlocking"
  s.version          = "5.0.1"
  s.summary          = "RxSwift Blocking operatos"
  s.description      = <<-DESC
Set of blocking operators for RxSwift. These operators are mostly intended for unit/integration tests
with a couple of other special scenarios where they could be useful.

E.g.

Waiting for observable sequence to complete before exiting command line application.
                        DESC
  s.homepage         = "https://github.com/ReactiveX/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/ReactiveX/RxSwift.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '9.0'

  s.source_files          = 'RxBlocking/**/*.swift', 'Platform/**/*.swift'
  s.exclude_files         = 'RxBlocking/Platform/**/*.swift'

  s.dependency 'RxSwift', '~> 5'
  s.swift_version = '5.0'
end
