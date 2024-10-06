Pod::Spec.new do |s|
  s.name             = "RxBlocking"
  s.version          = "6.8.0"
  s.summary          = "RxSwift Blocking operators"
  s.description      = <<-DESC
Set of blocking operators for RxSwift. These operators are mostly intended for unit/integration tests
with a couple of other special scenarios where they could be useful.

E.g.

Waiting for observable sequence to complete before exiting command line application.
                        DESC
  s.homepage         = "https://github.com/ReactiveX/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Shai Mishali" => "freak4pc@gmail.com", "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/ReactiveX/RxSwift.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '9.0'
  s.visionos.deployment_target = "1.0" if s.respond_to?(:visionos)

  s.source_files          = 'RxBlocking/**/*.swift', 'Platform/**/*.swift'
  s.exclude_files         = 'RxBlocking/Platform/**/*.swift'

  s.dependency 'RxSwift', '6.8.0'
  s.swift_version = '5.1'

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
end
