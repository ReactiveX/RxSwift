//
//  WikipediaSearchCell.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public class WikipediaSearchCell: UITableViewCell {

    @IBOutlet var titleOutlet: UILabel!
    @IBOutlet var URLOutlet: UILabel!
    @IBOutlet var imagesOutlet: UICollectionView!

    var disposeBag: DisposeBag!

    let imageService = DefaultImageService.sharedImageService

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.imagesOutlet.registerNib(UINib(nibName: "WikipediaImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }

    var viewModel: SearchResultViewModel! {
        didSet {
            let disposeBag = DisposeBag()

            (viewModel?.title ?? Drive.just(""))
                .drive(self.titleOutlet.rx_text)
                .addDisposableTo(disposeBag)

            self.URLOutlet.text = viewModel.searchResult.URL.absoluteString ?? ""

            viewModel.imageURLs
                .drive(self.imagesOutlet.rx_itemsWithCellIdentifier("ImageCell")) { [unowned self] (_, URL, cell: CollectionViewImageCell) in
                    cell.downloadableImage = self.imageService.imageFromURL(URL)
                }
                .addDisposableTo(disposeBag)

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
