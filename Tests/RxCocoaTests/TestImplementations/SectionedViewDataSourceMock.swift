//
//  SectionedViewDataSourceMock.swift
//  Tests
//
//  Created by Krunoslav Zaher on 1/10/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

@objc final class SectionedViewDataSourceMock
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

    func model(at indexPath: IndexPath) throws -> Any {
        return items![indexPath.item]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        items = observedEvent.element!
    }

    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        items = observedEvent.element!
    }
}
