//
//  Deprecated.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 10/8/17.
//  Copyright © 2017 kzaher. All rights reserved.
//

extension CollectionViewSectionedDataSource {
    @available(*, deprecated, renamed: "configureSupplementaryView")
    public var supplementaryViewFactory: ConfigureSupplementaryView {
        get {
            return self.configureSupplementaryView
        }
        set {
            self.configureSupplementaryView = newValue
        }
    }
}
