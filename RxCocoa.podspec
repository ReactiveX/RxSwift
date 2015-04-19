Pod::Spec.new do |s|
  s.name             = "RxCocoa"
  s.version          = "0.8"
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

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'RxCocoa/RxCocoa/**/*'

  s.dependency 'RxSwift'
end
