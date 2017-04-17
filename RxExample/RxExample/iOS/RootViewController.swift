//
//  RootViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

public class RootViewController : UITableViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        // force load
        _ = GitHubSearchRepositoriesAPI.sharedAPI
        _ = DefaultWikipediaAPI.sharedAPI
        _ = DefaultImageService.sharedImageService
        _ = DefaultWireframe.shared
        _ = MainScheduler.instance
        _ = Dependencies.sharedDependencies.reachabilityService
        
        let geoService = GeolocationService.instance
        geoService.authorized.drive(onNext: { _ in

        }).dispose()
        geoService.location.drive(onNext: { _ in

        }).dispose()
    }
}
