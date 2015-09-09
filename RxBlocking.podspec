Pod::Spec.new do |s|
  s.name             = "RxBlocking"
  s.version          = "2.0.0-alpha.2"
  s.summary          = "RxSwift Blocking operatos"
  s.description      = <<-DESC
                        Set of blocking operators for unit testing
                        DESC
  s.homepage         = "https://github.com/ReactiveX/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/ReactiveX/RxSwift.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files          = 'RxBlocking/**/*.swift'

  s.dependency 'RxSwift', '~> 2.0.0-alpha'
end
