Pod::Spec.new do |s|
  s.name             = "RxCocoa"
  s.version          = "6.9.0"
  s.summary          = "RxSwift Cocoa extensions"
  s.description      = <<-DESC
* UI extensions
* NSURL extensions
* KVO extensions
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

  s.header_dir            = "RxCocoa"
  s.source_files          = 'RxCocoa/**/*.{swift,h,m}', 'Platform/**/*.swift'
  s.exclude_files         = 'RxCocoa/Platform/**/*.swift', 'Platform/AtomicInt.swift'

  s.dependency 'RxSwift', '6.9.0'
  s.dependency 'RxRelay', '6.9.0'

  s.resource_bundles = {
    'RxCocoa_Privacy' => ['Sources/RxCocoa/PrivacyInfo.xcprivacy'],
  }

  s.swift_version = '5.1'

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
end
