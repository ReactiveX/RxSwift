Pod::Spec.new do |s|
  s.name             = "RxTest"
  s.version          = "4.0.0"
  s.summary          = "RxSwift Testing extensions"
  s.description      = <<-DESC
Unit testing extensions for RxSwift. This library contains mock schedulers, observables, and observers
that should make unit testing your operators easy as unit testing RxSwift built-in operators.

This library contains everything you needed to write unit tests in the following way:
```swift
func testMap() {
    let scheduler = TestScheduler(initialClock: 0)

    let xs = scheduler.createHotObservable([
        next(150, 1),
        next(210, 0),
        next(220, 1),
        next(230, 2),
        next(240, 4),
        completed(300)
        ])

    let res = scheduler.start { xs.map { $0 * 2 } }

    let correctEvents = [
        next(210, 0 * 2),
        next(220, 1 * 2),
        next(230, 2 * 2),
        next(240, 4 * 2),
        completed(300)
    ]

    let correctSubscriptions = [
        Subscription(200, 300)
    ]

    XCTAssertEqual(res.events, correctEvents)
    XCTAssertEqual(xs.subscriptions, correctSubscriptions)
}
```

                        DESC
  s.homepage         = "https://github.com/ReactiveX/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/ReactiveX/RxSwift.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'

  s.source_files          = 'RxTest/**/*.swift', 'Platform/**/*.swift'
  s.exclude_files         = 'RxTest/Platform/**/*.swift'

  s.framework    = 'XCTest'

  s.dependency 'RxSwift', '~> 4.0'

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
end
