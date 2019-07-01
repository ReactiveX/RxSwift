//
//  WikipediaSearchCell.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class WikipediaSearchCell: UITableViewCell {

    @IBOutlet var titleOutlet: UILabel!
    @IBOutlet var URLOutlet: UILabel!
    @IBOutlet var imagesOutlet: UICollectionView!

    var disposeBag: DisposeBag?

    let imageService = DefaultImageService.sharedImageService

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.imagesOutlet.register(UINib(nibName: "WikipediaImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }

    var viewModel: SearchResultViewModel? {
        didSet {
            let disposeBag = DisposeBag()

            guard let viewModel = viewModel else {
                return
            }

            viewModel.title
                .map(Optional.init)
                .drive(self.titleOutlet.rx.text)
                .disposed(by: disposeBag)

            self.URLOutlet.text = viewModel.searchResult.URL.absoluteString

            let reachabilityService = Dependencies.sharedDependencies.reachabilityService
            viewModel.imageURLs
                .drive(self.imagesOutlet.rx.items(cellIdentifier: "ImageCell", cellType: CollectionViewImageCell.self)) { [weak self] (_, url, cell) in
                    cell.downloadableImage = self?.imageService.imageFromURL(url, reachabilityService: reachabilityService) ?? Observable.empty()

                    #if DEBUG
                        //cell.installHackBecauseOfAutomationLeaksOnIOS10(firstViewThatDoesntLeak: self!.superview!.superview!)
                    #endif
                }
                .disposed(by: disposeBag)

            self.disposeBag = disposeBag

            #if DEBUG
                self.installHackBecauseOfAutomationLeaksOnIOS10(firstViewThatDoesntLeak: self.superview!.superview!)
            #endif
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil
        self.disposeBag = nil
    }

    deinit {
    }

}

private protocol ReusableView: class {
    var disposeBag: DisposeBag? { get }
    func prepareForReuse()
}

extension WikipediaSearchCell : ReusableView {

}

extension CollectionViewImageCell : ReusableView {

}

private extension ReusableView {
    func installHackBecauseOfAutomationLeaksOnIOS10(firstViewThatDoesntLeak: UIView) {
        if #available(iOS 10.0, *) {
            if OSApplication.isInUITest  {
                // !!! on iOS 10 automation tests leak cells, 🍻 automation team
                // !!! fugly workaround
                // ... no, I'm not assuming prepareForReuse is always called before init, this is
                // just a workaround because that method already has cleanup logic :(
                // Remember that leaking UISwitch?
                // https://github.com/ReactiveX/RxSwift/issues/842
                // Well it just got some new buddies to hang around with
                firstViewThatDoesntLeak.rx.deallocated.subscribe(onNext: { [weak self] _ in
                        self?.prepareForReuse()
                    })
                    .disposed(by: self.disposeBag!)
            }
        }
    }
}
