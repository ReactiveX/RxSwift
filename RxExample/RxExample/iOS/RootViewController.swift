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
        GitHubSearchRepositoriesAPI.sharedAPI.activityIndicator
        DefaultWikipediaAPI.sharedAPI
        DefaultImageService.sharedImageService
        DefaultWireframe.sharedInstance
        MainScheduler.instance
        ReachabilityService.sharedReachabilityService
        let geoService = GeolocationService.instance
        geoService.autorized.driveNext { _ in

        }.dispose()
        geoService.location.driveNext { _ in

        }.dispose()
    }
}