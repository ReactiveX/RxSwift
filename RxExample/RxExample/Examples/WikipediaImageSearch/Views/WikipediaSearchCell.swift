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
                        let loadingPlaceholder:UIImage? = nil
                        let loadingPlaceholderOnError:UIImage? = self.loadingPlaceholderWithFrame(cell.bounds)

                        cell.image = self.imageService.imageFromURL(URL)
                            .map { $0 as UIImage? }
                            .retryOnBecomesReachable(loadingPlaceholderOnError, reachabilityService: ReachabilityService.sharedReachabilityService)
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

    private func loadingPlaceholderWithFrame(frame:CGRect)->UIImage{
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)

        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Text Drawing
        let textRect = CGRectMake(frame.minX + floor((frame.width - 100) / 2 + 0.5), frame.minY + floor((frame.height - 21) * 0.49367 + 0.5), 100, 21)
        let textTextContent = NSString(string: "Loading")
        let textStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = .Center

        let textFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(UIFont.smallSystemFontSize()), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: textStyle]

        let textTextHeight: CGFloat = textTextContent.boundingRectWithSize(CGSizeMake(textRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, textRect);
        textTextContent.drawInRect(CGRectMake(textRect.minX, textRect.minY + (textRect.height - textTextHeight) / 2, textRect.width, textTextHeight), withAttributes: textFontAttributes)
        CGContextRestoreGState(context)
        let imageOfCanvas1 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageOfCanvas1
        
    }

    deinit {
    }

}
