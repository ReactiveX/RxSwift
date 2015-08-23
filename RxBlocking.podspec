Pod::Spec.new do |s|
  s.name             = "RxBlocking"
  s.version          = "1.9.1"
  s.summary          = "RxSwift Blocking operatos"
  s.description      = <<-DESC
                        Set of blocking operators for unit testing
                        DESC
  s.homepage         = "https://github.com/kzaher/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/kzaher/RxSwift.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files          = 'RxBlocking/RxBlocking/**/*.swift'

  s.dependency 'RxSwift', '~> 1.0'
end
