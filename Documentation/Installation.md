## Build / Install / Run

Rx doesn't contain any external dependencies.

These are currently supported options:

### Manual

Open Rx.xcworkspace, choose `RxExample` and hit run. This method will build everything and run sample app

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

**:warning: IMPORTANT! For tvOS support CocoaPods `0.39` is required. :warning:**

```
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'RxSwift',    '~> 2.0'
    pod 'RxCocoa',    '~> 2.0'
    pod 'RxBlocking', '~> 2.0'
    pod 'RxTests',    '~> 2.0'
end
```

replace `YOUR_TARGET_NAME`, then type in the `Podfile` directory:

```
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

**Xcode 7.1 required**

Add this to `Cartfile`

```
github "ReactiveX/RxSwift" ~> 2.0
```

```
$ carthage update
```

### Manually using git submodules

* Add RxSwift as a submodule

```
$ git submodule add git@github.com:ReactiveX/RxSwift.git
```

* Drag `Rx.xcodeproj` into Project Navigator
* Go to `Project > Targets > Build Phases > Link Binary With Libraries`, click `+` and select `RxSwift-[Platform]` and `RxCocoa-[Platform]` targets
