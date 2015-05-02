//
//  WikipediaSearchCell.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public class WikipediaSearchCell: UITableViewCell {
    
    @IBOutlet var titleOutlet: UILabel!
    @IBOutlet var URLOutlet: UILabel!
    @IBOutlet var imagesOutlet: UICollectionView!
    
    var disposeBag: DisposeBag!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imagesOutlet.registerNib(UINib(nibName: "WikipediaImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }
    
    var viewModel: SearchResultViewModel! {
        didSet {
            let $ = viewModel.$
            
            let disposeBag = DisposeBag()
    
            self.titleOutlet.rx_subscribeTextTo(viewModel?.title ?? returnElement("")) >- disposeBag.addDisposable
            self.URLOutlet.text = viewModel.searchResult.URL.absoluteString ?? ""
            
            viewModel.imageURLs
                >- self.imagesOutlet.rx_subscribeItemsWithIdentifierTo("ImageCell") { (_, _, URL, cell: CollectionViewImageCell) in
                    let loadingPlaceholder: UIImage? = nil
                    
                    cell.image = $.imageService.imageFromURL(URL)
                        >- map { $0 as UIImage? }
                        >- catch(nil)
                        >- prefixWith(loadingPlaceholder)
                } >- disposeBag.addDisposable
            
            self.disposeBag = disposeBag
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = nil
    }
    
    deinit {
    }
}