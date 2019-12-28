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
        items![indexPath.item]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        items = observedEvent.element!
    }

    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        items = observedEvent.element!
    }
}
