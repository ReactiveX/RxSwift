//
//  DetailViewController.swift
//  RxExample
//
//  Created by carlos on 26/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

class DetailViewController: ViewController {
    
    var user: User!
    
    let $ = Dependencies.sharedDependencies
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        imageView.makeRoundedCorners(5)
        
        let url = NSURL(string: user.imageURL)!
        let request = NSURLRequest(URL: url)
        
        NSURLSession.sharedSession().rx_data(request)
            .map { data in
                UIImage(data: data)
            }
            .observeOn($.mainScheduler)
            .subscribe(imageView.rx_image)
            .addDisposableTo(disposeBag)
        
        label.text = user.firstName + " " + user.lastName
    }

}
