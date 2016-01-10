//
//  SectionedViewDataSourceMock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 1/10/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

@objc class SectionedViewDataSourceMock
    : NSObject
    , SectionedViewDataSourceType
    , UITableViewDataSource
    , UICollectionViewDataSource
    , RxTableViewDataSourceType
    , RxCollectionViewDataSourceType {

    typealias Element = [Int]

    var items: [Int]?

    override init() {
        super.init()
    }

    func modelAtIndexPath(indexPath: NSIndexPath) throws -> Any {
        return items![indexPath.item]
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

    func tableView(tableView: UITableView, observedEvent: Event<Element>) {
        items = observedEvent.element!
    }

    func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        items = observedEvent.element!
    }
}