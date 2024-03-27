//
//  RxDiffableDataSourceType.swift
//  RxCocoa
//
//  Created by mlch911 on 2023/6/7.
//

import Foundation

protocol RxDiffableDataSourceType {
	func model(for indexPath: IndexPath) -> Any?
}
