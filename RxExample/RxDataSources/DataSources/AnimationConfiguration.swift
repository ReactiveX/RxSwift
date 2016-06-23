//
//  AnimationConfiguration.swift
//  RxDataSources
//
//  Created by Esteban Torres on 5/2/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit

/**
   Exposes custom animation styles for insertion, deletion and reloading behavior.
*/
public struct AnimationConfiguration {
  let insertAnimation: UITableViewRowAnimation
  let reloadAnimation: UITableViewRowAnimation
  let deleteAnimation: UITableViewRowAnimation
  
  public init(insertAnimation: UITableViewRowAnimation = .automatic,
    reloadAnimation: UITableViewRowAnimation = .automatic,
    deleteAnimation: UITableViewRowAnimation = .automatic) {
      self.insertAnimation = insertAnimation
      self.reloadAnimation = reloadAnimation
      self.deleteAnimation = deleteAnimation
  }
}
