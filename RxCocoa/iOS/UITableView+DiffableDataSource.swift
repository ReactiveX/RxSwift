//
//  UITableView+DiffableDataSource.swift
//  RxCocoa
//
//  Created by mlch911 on 2023/6/7.
//

import Foundation

extension UITableView {
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

extension UITableViewDiffableDataSourceReference: RxDiffableDataSourceType {
	func model(for indexPath: IndexPath) -> Any? {
		itemIdentifier(for: indexPath)
	}
}

extension UITableViewDiffableDataSource: RxDiffableDataSourceType {
	func model(for indexPath: IndexPath) -> Any? {
		itemIdentifier(for: indexPath)
	}
}
