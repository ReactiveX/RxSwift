//
//  AnimationConfiguration.swift
//  RxDataSources
//
//  Created by Esteban Torres on 5/2/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import Foundation
    import UIKit

    /**
     Exposes custom animation styles for insertion, deletion and reloading behavior.
     */
    public struct AnimationConfiguration {
        public let insertAnimation: UITableView.RowAnimation
        public let reloadAnimation: UITableView.RowAnimation
        public let deleteAnimation: UITableView.RowAnimation

        public init(insertAnimation: UITableView.RowAnimation = .automatic,
                    reloadAnimation: UITableView.RowAnimation = .automatic,
                    deleteAnimation: UITableView.RowAnimation = .automatic) {
            self.insertAnimation = insertAnimation
            self.reloadAnimation = reloadAnimation
            self.deleteAnimation = deleteAnimation
        }
    }
#endif
