<img src="assets/Rx_Logo_M.png" alt="Miss Electric Eel 2016" width="36" height="36"> RxSwift: ReactiveX for Swift
======================================

[![Travis CI](https://travis-ci.org/ReactiveX/RxSwift.svg?branch=master)](https://travis-ci.org/ReactiveX/RxSwift) ![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OSX%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux%28experimental%29-333333.svg) ![pod](https://img.shields.io/cocoapods/v/RxSwift.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


Xcode 7 Swift 2.1 required

## About Rx

Rx is a [generic abstraction of computation](https://youtu.be/looJcaeboBY) expressed through `Observable<Element>` interface.

This is a Swift version of [Rx](https://github.com/Reactive-Extensions/Rx.NET).

It tries to port as many concepts from the original version as possible, but some concepts were adapted for more pleasant and performant integration with iOS/OSX environment.

Cross platform documentation can be found on [ReactiveX.io](http://reactivex.io/).

Like the original Rx, its intention is to enable easy composition of asynchronous operations and event/data streams.

KVO observing, async operations and streams are all unified under [abstraction of sequence](Documentation/GettingStarted.md#observables-aka-sequences). This is the reason why Rx is so simple, elegant and powerful.

## I came here because I want to ...

###### ... understand

* [why use rx?](Documentation/Why.md)
* [the basics, getting started with RxSwift](Documentation/GettingStarted.md)
* [units](Documentation/Units.md) - what is `Driver`, `ControlProperty`, and `Variable` ... and why do they exist?
* [testing](Documentation/UnitTests.md)
* [tips and common errors](Documentation/Tips.md)
* [debugging](Documentation/GettingStarted.md#debugging)
* [the math behind Rx](Documentation/MathBehindRx.md)
* [what are hot and cold observable sequences?](Documentation/HotAndColdObservables.md)
* [what does the the public API look like?](Documentation/API.md)

###### ... install

* Integrate RxSwift/RxCocoa with my app. [Installation Guide](Documentation/Installation.md)

###### ... hack around

* with example app. [Running Example App](Documentation/ExampleApp.md)
* with operators in playgrounds. [Playgrounds](Documentation/Playgrounds.md)

###### ... interact

* All of this is great, but it would be nice to talk with other people using RxSwift and exchange experiences. <br />[![Slack channel](http://slack.rxswift.org/badge.svg)](http://slack.rxswift.org) [Join Slack Channel](http://slack.rxswift.org/)
* Report a problem using the library. [Open an Issue With Bug Template](Documentation/IssueTemplate.md)
* Request a new feature. [Open an Issue With Feature Request Template](Documentation/NewFeatureRequestTemplate.md)


###### ... compare

* [with other libraries](Documentation/ComparisonWithOtherLibraries.md).


###### ... find compatible

* libraries from [RxSwiftCommunity](https://github.com/RxSwiftCommunity).
* [Pods using RxSwift](https://cocoapods.org/?q=uses%3Arxswift).

###### ... see the broader vision

* Does this exist for Android? [RxJava](https://github.com/ReactiveX/RxJava)
* Where is all of this going, what is the future, what about reactive architectures, how do you design entire apps this way? [Cycle.js](https://github.com/cyclejs/cycle-core) - this is javascript, but [RxJS](https://github.com/Reactive-Extensions/RxJS) is javascript version of Rx.

##### References

* [http://reactivex.io/](http://reactivex.io/)
* [Reactive Extensions GitHub (GitHub)](https://github.com/Reactive-Extensions)
* [Erik Meijer (Wikipedia)](http://en.wikipedia.org/wiki/Erik_Meijer_%28computer_scientist%29)
* [Expert to Expert: Brian Beckman and Erik Meijer - Inside the .NET Reactive Framework (Rx) (video)](https://youtu.be/looJcaeboBY)
* [Reactive Programming Overview (Jafar Husain from Netflix)](https://www.youtube.com/watch?v=dwP1TNXE6fc)
* [Subject/Observer is Dual to Iterator (paper)](http://csl.stanford.edu/~christos/pldi2010.fit/meijer.duality.pdf)
* [Rx standard sequence operators visualized (visualization tool)](http://rxmarbles.com/)
* [Haskell](https://www.haskell.org/)
