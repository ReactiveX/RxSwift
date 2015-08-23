Pod::Spec.new do |s|
  s.name             = "RxCocoa"
  s.version          = "1.9.1"
  s.summary          = "RxSwift Cocoa extensions"
  s.description      = <<-DESC
			* UI extensions
			* NSURL extensions
			* KVO extensions
                        DESC
  s.homepage         = "https://github.com/kzaher/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/kzaher/RxSwift.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files          = 'RxCocoa/RxCocoa/RxCocoa.h', 'RxCocoa/RxCocoa/Common/**/*.{swift,h,m}'
  s.ios.source_files      = 'RxCocoa/RxCocoa/iOS/**/*.swift'
  s.osx.source_files      = 'RxCocoa/RxCocoa/OSX/**/*.swift'

  s.dependency 'RxSwift', '~> 1.0'
end
