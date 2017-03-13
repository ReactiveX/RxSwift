Pod::Spec.new do |s|
  s.name             = "RxCocoa"
  s.version          = "3.3.1"
  s.summary          = "RxSwift Cocoa extensions"
  s.description      = <<-DESC
* UI extensions
* NSURL extensions
* KVO extensions
                        DESC
  s.homepage         = "https://github.com/ReactiveX/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/ReactiveX/RxSwift.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.source_files          = 'RxCocoa/RxCocoa.h', 'RxCocoa/RxCocoa.swift', 'RxCocoa/Common/**/*.{swift,h,m}', 'RxCocoa/CocoaUnits/**/*.{swift,h,m}', 'RxCocoa/Foundation/**/*.{swift,h,m}', 'RxCocoa/Runtime/**/*.{swift,h,m}', 'Platform/**/*.swift'
  s.exclude_files         = 'RxCocoa/Platform/**/*.swift'

  s.ios.source_files      = 'RxCocoa/iOS/**/*.swift'
  s.osx.source_files      = 'RxCocoa/macOS/**/*.swift'
  s.watchos.source_files  = 'RxCocoa/iOS/**/*.swift'
  s.tvos.source_files     = 'RxCocoa/iOS/**/*.swift'

  s.dependency 'RxSwift', '~> 3.3'
end
