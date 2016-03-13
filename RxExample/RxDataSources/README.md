RxSwift: DataSources
====================

This directory contains example implementations of reactive data sources.

Reactive data sources are normal data sources + one additional method

**This code has been packed in [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) project.**

```swift

func view(view: UIXXXView, observedEvent: Event<Element>) {}

```

That means that data sources now have additional responsibility of updating the corresponding view.

For now this will be a directory in Rx project with a couple of files that you can just copy and customize. 

It's possible that in the future this will be extracted into separate repository and CocoaPod.

It's really hard to satisfy all needs with one codebase regarding these orthogonal dimensions:

* how do you determine identity of objects
* how to determine the structure of data source
* how to determine is object updated
* are objects structures or references
* are differences between transitions already precalculated in some form (I'm looking at you NSFetchedResultsController)
* ....

So instead of doing all things mediocre, you can use these couple of lines of code to code up your own optimized solution.

The code in this directory includes these features:

* using rows or sections as DataSources for UICollectionView or UITableView
* unified sectioned view interface
* automatic animated partial updates with O(n) complexity (it will generate all updates to sections and items)

Example project uses these files to implement partial updates in `Reactive partial updates` example.

The only problem regarding partial updates that is not solved perfectly is UICollectionView. 
Unfortunately UICollectionView has some weird problems with internal state. 
For same set of changes, depending on clicking speed it will sometimes get out of sync with data source.

The changes in example problem are pseudorandom (they always use the same seed), so you will be able to sometimes crash UICollectionView by clicking fast, but it will be ok if you click slow :(

The problem isn't in the differential algorithm, but in UICollectionView itself, so not sure how to solve it perfectly.
Any suggestions are welcome.

UITableView on the other hand passed all stress tests. (You can run stress tests with random changes in example project)
