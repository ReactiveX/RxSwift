//
//  DetailViewController.swift
//  RxExample
//
//  Created by carlos on 26/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift

class DetailViewController: ViewController {
    
    weak var masterVC: TableViewController!
    var user: User!
    
    let $ = Dependencies.sharedDependencies
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        imageView.makeRoundedCorners(5)
        
        let url = NSURL(string: user.imageURL)!
        let request = NSURLRequest(URL: url)
        
        NSURLSession.sharedSession().rx_data(request)
            >- map { data in
                UIImage(data: data)
            }
            >- observeSingleOn($.mainScheduler)
            >- imageView.rx_subscribeImageTo
            >- disposeBag.addDisposable
        
        label.text = user.firstName + " " + user.lastName
    }

}
