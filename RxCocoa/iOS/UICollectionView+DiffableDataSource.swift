//
//  UICollectionView+DiffableDataSource.swift
//  RxCocoa
//
//  Created by mlch911 on 2023/6/1.
//

import Foundation

extension UICollectionView {
	func isDiffableDataSource() -> Bool {
		diffableDataSource() != nil
	}
	
	func diffableDataSource() -> RxDiffableDataSourceType? {
		if #available(iOS 13.0, tvOS 13.0, *) {
			return dataSource as? RxDiffableDataSourceType
		}
		return nil
	}
}

extension UICollectionViewDiffableDataSourceReference: RxDiffableDataSourceType {
	func model(for indexPath: IndexPath) -> Any? {
		itemIdentifier(for: indexPath)
	}
}

extension UICollectionViewDiffableDataSource: RxDiffableDataSourceType {
	func model(for indexPath: IndexPath) -> Any? {
		itemIdentifier(for: indexPath)
	}
}
