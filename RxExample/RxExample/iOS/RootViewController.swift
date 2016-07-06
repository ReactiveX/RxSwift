//
//  RootViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

public class RootViewController : UITableViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        // force load
        _ = GitHubSearchRepositoriesAPI.sharedAPI.activityIndicator
        _ = DefaultWikipediaAPI.sharedAPI
        _ = DefaultImageService.sharedImageService
        _ = DefaultWireframe.sharedInstance
        _ = MainScheduler.instance
        let geoService = GeolocationService.instance
        geoService.authorized.driveNext { _ in

        }.dispose()
        geoService.location.driveNext { _ in

        }.dispose()
    }
}
