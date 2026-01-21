//
//  Deprecated.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 10/8/17.
//  Copyright © 2017 kzaher. All rights reserved.
//

public extension CollectionViewSectionedDataSource {
    @available(*, deprecated, renamed: "configureSupplementaryView")
    var supplementaryViewFactory: ConfigureSupplementaryView {
        get {
            configureSupplementaryView
        }
        set {
            configureSupplementaryView = newValue
        }
    }
}
