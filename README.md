<p align="center">
<img src="https://github.com/ReactiveX/RxSwift/blob/main/assets/RxSwift_Logo.png?raw=true" width="35%" alt="RxSwift Logo" />
<br />
<a href="https://actions-badge.atrox.dev/ReactiveX/RxSwift/goto" target="_blank"><img src="https://github.com/ReactiveX/RxSwift/workflows/RxSwift/badge.svg?branch=main" alt="Build Status" /></a>
<img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-333333.svg" alt="Supported Platforms: iOS, macOS, tvOS, watchOS & Linux" />
<br />
<a href="https://cocoapods.org/pods/RxSwift" alt="RxSwift on CocoaPods" title="RxSwift on CocoaPods"><img src="https://img.shields.io/cocoapods/v/RxSwift.svg" /></a>
<a href="https://github.com/Carthage/Carthage" alt="RxSwift on Carthage" title="RxSwift on Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" /></a>
<a href="https://github.com/apple/swift-package-manager" alt="RxSwift on Swift Package Manager" title="RxSwift on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>
</p>

Rx is a [generic abstraction of computation](https://youtu.be/looJcaeboBY) expressed through `Observable<Element>` interface, which lets you broadcast and subscribe to values and other events from an `Observable` stream.  

RxSwift is the Swift-specific implementation of the [Reactive Extensions](http://reactivex.io) standard.

<p align="center"><img src="https://github.com/ReactiveX/RxSwift/blob/main/assets/example.png?raw=true" width="55%" alt="RxSwift Observable Example of a price constantly changing and updating the app's UI" /></p>

While this version aims to stay true to the original spirit and naming conventions of Rx, this project also aims to provide a true Swift-first API for Rx APIs.

Cross platform documentation can be found on [ReactiveX.io](http://reactivex.io/).

Like other Rx implementations, RxSwift's intention is to enable easy composition of asynchronous operations and streams of data in the form of `Observable` objects and a suite of methods to transform and compose these pieces of asynchronous work.

KVO observation, async operations, UI Events and other streams of data are all unified under [abstraction of sequence](Documentation/GettingStarted.md#observables-aka-sequences). This is the reason why Rx is so simple, elegant and powerful.

## I came here because I want to ...

###### ... understand

* [why use rx?](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/Why.md)
* [the basics, getting started with RxSwift](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/GettingStarted.md)
* [traits](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/Traits.md) - what are `Single`, `Completable`, `Maybe`, `Driver`, and `ControlProperty` ... and why do they exist?
* [testing](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/UnitTests.md)
* [tips and common errors](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/Tips.md)
* [debugging](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/GettingStarted.md#debugging)
* [the math behind Rx](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/MathBehindRx.md)
* [what are hot and cold observable sequences?](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/HotAndColdObservables.md)

###### ... install

* Integrate RxSwift/RxCocoa with my app. [Installation Guide](#installation)

###### ... hack around

* with the example app. [Running Example App](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/ExampleApp.md)
* with operators in playgrounds. [Playgrounds](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/Playgrounds.md)

###### ... interact

* All of this is great, but it would be nice to talk with other people using RxSwift and exchange experiences. <br />[Join Slack Channel](http://slack.rxswift.org)
* Report a problem using the library. [Open an Issue With Bug Template](https://github.com/ReactiveX/RxSwift/blob/main/.github/ISSUE_TEMPLATE.md)
* Request a new feature. [Open an Issue With Feature Request Template](Documentation/NewFeatureRequestTemplate.md)
* Help out [Check out contribution guide](https://github.com/ReactiveX/RxSwift/blob/main/CONTRIBUTING.md)

###### ... compare

* [with Combine and ReactiveSwift](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/ComparisonWithOtherLibraries.md).

###### ... understand the structure

RxSwift is as compositional as the asynchronous work it drives. The core unit is RxSwift itself, while other dependencies can be added for UI Work, testing, and more.

It comprises five separate components depending on each other in the following way:

```none
┌──────────────┐    ┌──────────────┐
│   RxCocoa    ├────▶   RxRelay    │
└───────┬──────┘    └──────┬───────┘
        │                  │        
┌───────▼──────────────────▼───────┐
│             RxSwift              │
└───────▲──────────────────▲───────┘
        │                  │        
┌───────┴──────┐    ┌──────┴───────┐
│    RxTest    │    │  RxBlocking  │
└──────────────┘    └──────────────┘
```

* **RxSwift**: The core of RxSwift, providing the Rx standard as (mostly) defined by [ReactiveX](https://reactivex.io). It has no other dependencies.
* **RxCocoa**: Provides Cocoa-specific capabilities for general iOS/macOS/watchOS & tvOS app development, such as Shared Sequences, Traits, and much more. It depends on both `RxSwift` and `RxRelay`.
* **RxRelay**: Provides `PublishRelay`, `BehaviorRelay` and `ReplayRelay`, three [simple wrappers around Subjects](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/Subjects.md#relays). It depends on `RxSwift`. 
* **RxTest** and **RxBlocking**: Provides testing capabilities for Rx-based systems. It depends on `RxSwift`.

## Usage

<table>
  <tr>
    <th width="30%">Here's an example</th>
    <th width="30%">In Action</th>
  </tr>
  <tr>
    <td>Define search for GitHub repositories ...</td>
    <th rowspan="9"><img src="https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/GithubSearch.gif"></th>
  </tr>
  <tr>
    <td><div class="highlight highlight-source-swift"><pre>
let searchResults = searchBar.rx.text.orEmpty
    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
    .distinctUntilChanged()
    .flatMapLatest { query -> Observable&lt;[Repository]&gt; in
        if query.isEmpty {
            return .just([])
        }
        return searchGitHub(query)
            .catchAndReturn([])
    }
    .observe(on: MainScheduler.instance)</pre></div></td>
  </tr>
  <tr>
    <td>... then bind the results to your tableview</td>
  </tr>
  <tr>
    <td width="30%"><div class="highlight highlight-source-swift"><pre>
searchResults
    .bind(to: tableView.rx.items(cellIdentifier: "Cell")) {
        (index, repository: Repository, cell) in
        cell.textLabel?.text = repository.name
        cell.detailTextLabel?.text = repository.url
    }
    .disposed(by: disposeBag)</pre></div></td>
  </tr>
</table>

## Installation

RxSwift doesn't contain any external dependencies.

These are currently the supported installation options:

### Manual

Open Rx.xcworkspace, choose `RxExample` and hit run. This method will build everything and run the sample app

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'RxSwift', '6.7.1'
    pod 'RxCocoa', '6.7.1'
end

# RxTest and RxBlocking make the most sense in the context of unit/integration tests
target 'YOUR_TESTING_TARGET' do
    pod 'RxBlocking', '6.7.1'
    pod 'RxTest', '6.7.1'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### XCFrameworks

Each release starting with RxSwift 6 includes `*.xcframework` framework binaries.

Simply drag the needed framework binaries to your **Frameworks, Libraries, and Embedded Content** section under your target's **General** tab.

<img src="https://raw.githubusercontent.com/ReactiveX/RxSwift/main/assets/xcframeworks.png" alt="XCFrameworks instructions" width="65%">

> [!TIP]
> You may verify the identity of the binaries by comparing against the following fingerprint in Xcode 15+:
>
> `BD 80 2E 79 4C 8A BD DA 4C 3F 5D 92 B3 E4 C4 FB FA E4 73 44 10 B9 AD 73 44 2E F1 CE B0 27 61 40`
>
> <img src="https://raw.githubusercontent.com/ReactiveX/RxSwift/main/assets/xcframeworks_signing.png" alt="XCFrameworks Signature Fingerprint in Xcode 15+" width="65%">

### [Carthage](https://github.com/Carthage/Carthage)

Add this to `Cartfile`

```
github "ReactiveX/RxSwift" "6.7.1"
```

```bash
$ carthage update
```

#### Carthage as a Static Library

Carthage defaults to building RxSwift as a Dynamic Library. 

If you wish to build RxSwift as a Static Library using Carthage you may use the script below to manually modify the framework type before building with Carthage:

```bash
carthage update RxSwift --platform iOS --no-build
sed -i -e 's/MACH_O_TYPE = mh_dylib/MACH_O_TYPE = staticlib/g' Carthage/Checkouts/RxSwift/Rx.xcodeproj/project.pbxproj
carthage build RxSwift --platform iOS
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

> **Note**: There is a critical cross-dependency bug affecting many projects including RxSwift in Swift Package Manager. We've [filed a bug (SR-12303)](https://bugs.swift.org/browse/SR-12303) in early 2020 but have no answer yet. Your mileage may vary. A partial workaround can be found [here](https://github.com/ReactiveX/RxSwift/issues/2127#issuecomment-717830502).

Create a `Package.swift` file.

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "RxProject",
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0"))
  ],
  targets: [
    .target(name: "RxProject", dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")]),
  ]
)
```

```bash
$ swift build
```

To build or test a module with RxTest dependency, set `TEST=1`.

```bash
$ TEST=1 swift test
```

### Manually using git submodules

* Add RxSwift as a submodule

```bash
$ git submodule add git@github.com:ReactiveX/RxSwift.git
```

* Drag `Rx.xcodeproj` into Project Navigator
* Go to `Project > Targets > Build Phases > Link Binary With Libraries`, click `+` and select `RxSwift`, `RxCocoa` and `RxRelay` targets

## References

* [http://reactivex.io/](http://reactivex.io/)
* [Reactive Extensions GitHub (GitHub)](https://github.com/Reactive-Extensions)
* [RxSwift RayWenderlich.com Book](https://store.raywenderlich.com/products/rxswift-reactive-programming-with-swift)
* [RxSwift: Debunking the myth of hard (YouTube)](https://www.youtube.com/watch?v=GdvLP0ZAhhc)
* [Boxue.io RxSwift Online Course](https://boxueio.com/series/rxswift-101) (Chinese 🇨🇳)
* [Expert to Expert: Brian Beckman and Erik Meijer - Inside the .NET Reactive Framework (Rx) (video)](https://youtu.be/looJcaeboBY)
* [Reactive Programming Overview (Jafar Husain from Netflix)](https://youtu.be/-8Y1-lE6NSA)
* [Subject/Observer is Dual to Iterator (paper)](http://csl.stanford.edu/~christos/pldi2010.fit/meijer.duality.pdf)
* [Rx standard sequence operators visualized (visualization tool)](http://rxmarbles.com/)
* [Haskell](https://www.haskell.org/)
