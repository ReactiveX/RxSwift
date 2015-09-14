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

            (viewModel?.title ?? just(""))
                .subscribe(self.titleOutlet.rx_text)
                .addDisposableTo(disposeBag)

            self.URLOutlet.text = viewModel.searchResult.URL.absoluteString ?? ""

            viewModel.imageURLs
                .bindTo(self.imagesOutlet.rx_itemsWithCellIdentifier("ImageCell")) { [unowned self] (_, URL, cell: CollectionViewImageCell) in
                        let loadingPlaceholder: UIImage? = nil

                        cell.image = self.imageService.imageFromURL(URL)
                            .map { $0 as UIImage? }
                            .catchErrorJustReturn(nil)
                            .startWith(loadingPlaceholder)
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
