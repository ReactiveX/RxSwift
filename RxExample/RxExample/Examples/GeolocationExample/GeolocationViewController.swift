//
//  GeolocationViewController.swift
//  RxExample
//
//  Created by Carlos García on 19/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import CoreLocation
import RxCocoa
import RxSwift
import UIKit

private extension Reactive where Base: UILabel {
    var coordinates: Binder<CLLocationCoordinate2D> {
        Binder(base) { label, location in
            label.text = "Lat: \(location.latitude)\nLon: \(location.longitude)"
        }
    }
}

class GeolocationViewController: ViewController {
    @IBOutlet private var noGeolocationView: UIView!
    @IBOutlet private var button: UIButton!
    @IBOutlet private var button2: UIButton!
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(noGeolocationView)

        let geolocationService = GeolocationService.instance

        geolocationService.authorized
            .drive(noGeolocationView.rx.isHidden)
            .disposed(by: disposeBag)

        geolocationService.location
            .drive(label.rx.coordinates)
            .disposed(by: disposeBag)

        button.rx.tap
            .bind { [weak self] _ in
                self?.openAppPreferences()
            }
            .disposed(by: disposeBag)

        button2.rx.tap
            .bind { [weak self] _ in
                self?.openAppPreferences()
            }
            .disposed(by: disposeBag)
    }

    private func openAppPreferences() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}
