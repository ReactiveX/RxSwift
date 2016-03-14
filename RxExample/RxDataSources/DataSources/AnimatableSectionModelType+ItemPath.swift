//
//  AnimatableSectionModelType+ItemPath.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 1/9/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Array where Element: AnimatableSectionModelType {
    subscript(index: ItemPath) -> Element.Item {
        return self[index.sectionIndex].items[index.itemIndex]
    }
}