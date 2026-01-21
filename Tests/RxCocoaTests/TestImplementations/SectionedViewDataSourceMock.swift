//
//  SectionedViewDataSourceMock.swift
//  Tests
//
//  Created by Krunoslav Zaher on 1/10/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

@objc final class SectionedViewDataSourceMock:
    NSObject,
    SectionedViewDataSourceType,
    UITableViewDataSource,
    UICollectionViewDataSource,
    RxTableViewDataSourceType,
    RxCollectionViewDataSourceType
{
    typealias Element = [Int]

    var items: [Int]?

    override init() {
        super.init()
    }

    func model(at indexPath: IndexPath) throws -> Any {
        items![indexPath.item]
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        0
    }

    func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        0
    }

    func collectionView(_: UICollectionView, cellForItemAt _: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }

    func tableView(_: UITableView, observedEvent: Event<Element>) {
        items = observedEvent.element!
    }

    func collectionView(_: UICollectionView, observedEvent: Event<Element>) {
        items = observedEvent.element!
    }
}
