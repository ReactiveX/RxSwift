Units
=====

This document will try to describe what are units, why are they a useful concept, how to use them and how to create them.

* [Why](#why)
* [Design Rationale](#design-rationale)
* ...

# Why

The purpose of units is to use the Swift compiler static type checking to prove your code is behaving like designed.

RxCocoa project already contains several units, but the most elaborate one is called `Driver`, so this unit will be used to explain the idea behind units.

`Driver` was named that way because it describes sequences that drive certain parts of the app. Those sequences will usually drive UI bindings, UI event pumps that keep your application responsive, but also drive application services, etc.

The purpose of `Driver` unit is to ensure the underlying observable sequence has the following properties.

* can't fail, all failures are being handled properly
* elements are delivered on main thread
* sequence computation resources are shared

TBD...
