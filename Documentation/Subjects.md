Subjects
========

All of behave exactly the same like described [here](http://reactivex.io/documentation/subject.html)

Relays
======

RxRelay provides two kinds of Relays: `PublishRelay` and `BehaviorRelay`.
They behave exactly like their parallel `Subject`s, with two changes:

- Relays never complete.
- Relays never emit errors.

In essence, Relays only emit `.next` events, and never terminate.