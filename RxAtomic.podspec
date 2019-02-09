Pod::Spec.new do |s|
  s.name             = "RxAtomic"
  s.version          = "4.4.1"
  s.summary          = "Atomic primitives for RxSwift"
  s.description      = <<-DESC
Atomic primitives for RxSwift.
                        DESC
  s.homepage         = "https://github.com/ReactiveX/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/ReactiveX/RxSwift.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '9.0'

  s.source_files          = 'RxAtomic/**/*.{c,h}'
end
