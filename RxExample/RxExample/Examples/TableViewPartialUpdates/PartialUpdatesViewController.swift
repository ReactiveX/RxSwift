//
//  PartialUpdatesViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

let generateCustomSize = true
let runAutomatically = false
let useAnimatedUpdateForCollectionView = false

/**
Code for reactive data sources is packed in [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) project.
*/
class PartialUpdatesViewController : ViewController {

    @IBOutlet weak var reloadTableViewOutlet: UITableView!
    @IBOutlet weak var partialUpdatesTableViewOutlet: UITableView!
    @IBOutlet weak var partialUpdatesCollectionViewOutlet: UICollectionView!

    var timer: NSTimer? = nil

    static let initialValue: [AnimatableSectionModel<String, Int>] = [
        NumberSection(model: "section 1", items: [1, 2, 3]),
        NumberSection(model: "section 2", items: [4, 5, 6]),
        NumberSection(model: "section 3", items: [7, 8, 9]),
        NumberSection(model: "section 4", items: [10, 11, 12]),
        NumberSection(model: "section 5", items: [13, 14, 15]),
        NumberSection(model: "section 6", items: [16, 17, 18]),
        NumberSection(model: "section 7", items: [19, 20, 21]),
        NumberSection(model: "section 8", items: [22, 23, 24]),
        NumberSection(model: "section 9", items: [25, 26, 27]),
        NumberSection(model: "section 10", items: [28, 29, 30])
        ]


    static let firstChange: [AnimatableSectionModel<String, Int>]? = nil

    var generator = Randomizer(rng: PseudoRandomGenerator(4, 3), sections: initialValue)

    var sections = Variable([NumberSection]())

    /**
     Code for reactive data sources is packed in [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) project.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // For UICollectionView, if another animation starts before previous one is finished, it will sometimes crash :(
        // It's not deterministic (because Randomizer generates deterministic updates), and if you click fast
        // It sometimes will and sometimes wont crash, depending on tapping speed.
        // I guess you can maybe try some tricks with timeout, hard to tell :( That's on Apple side.

        if generateCustomSize {
            let nSections = 10
            let nItems = 100

            var sections = [AnimatableSectionModel<String, Int>]()

            for i in 0 ..< nSections {
                sections.append(AnimatableSectionModel(model: "Section \(i + 1)", items: Array(i * nItems ..< (i + 1) * nItems)))
            }

            generator = Randomizer(rng: PseudoRandomGenerator(4, 3), sections: sections)
        }

        #if runAutomatically
            timer = NSTimer.scheduledTimerWithTimeInterval(0.6, target: self, selector: "randomize", userInfo: nil, repeats: true)
        #endif

        self.sections.value = generator.sections

        let tvAnimatedDataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        let reloadDataSource = RxTableViewSectionedReloadDataSource<NumberSection>()

        skinTableViewDataSource(tvAnimatedDataSource)
        skinTableViewDataSource(reloadDataSource)

        self.sections.asObservable()
            .bindTo(partialUpdatesTableViewOutlet.rx_itemsWithDataSource(tvAnimatedDataSource))
            .addDisposableTo(disposeBag)

        self.sections.asObservable()
            .bindTo(reloadTableViewOutlet.rx_itemsWithDataSource(reloadDataSource))
            .addDisposableTo(disposeBag)

        // Collection view logic works, but when clicking fast because of internal bugs
        // collection view will sometimes get confused. I know what you are thinking,
        // but this is really not a bug in the algorithm. The generated changes are
        // pseudorandom, and crash happens depending on clicking speed.
        //
        // More info in `RxDataSourceStarterKit/README.md`
        //
        // If you want, turn this to true, just click slow :)
        //
        // While `useAnimatedUpdateForCollectionView` is false, you can click as fast as
        // you want, table view doesn't seem to have same issues like collection view.

        #if useAnimatedUpdateForCollectionView
            let cvAnimatedDataSource = RxCollectionViewSectionedAnimatedDataSource<NumberSection>()
            skinCollectionViewDataSource(cvAnimatedDataSource)

            updates
                .bindTo(partialUpdatesCollectionViewOutlet.rx_itemsWithDataSource(cvAnimatedDataSource))
                .addDisposableTo(disposeBag)
        #else
            let cvReloadDataSource = RxCollectionViewSectionedReloadDataSource<NumberSection>()
            skinCollectionViewDataSource(cvReloadDataSource)
            self.sections.asObservable()
                .bindTo(partialUpdatesCollectionViewOutlet.rx_itemsWithDataSource(cvReloadDataSource))
                .addDisposableTo(disposeBag)
        #endif

        // touches

        partialUpdatesCollectionViewOutlet.rx_itemSelected
            .subscribeNext { [weak self] i in
                print("Let me guess, it's .... It's \(self?.generator.sections[i.section].items[i.item]), isn't it? Yeah, I've got it.")
            }
            .addDisposableTo(disposeBag)

        Observable.of(partialUpdatesTableViewOutlet.rx_itemSelected, reloadTableViewOutlet.rx_itemSelected)
            .merge()
            .subscribeNext { [weak self] i in
                print("I have a feeling it's .... \(self?.generator.sections[i.section].items[i.item])?")
            }
            .addDisposableTo(disposeBag)
    }

    func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<NumberSection>) {
        dataSource.configureCell = { (_, tv, ip, i) in
            let cell = tv.dequeueReusableCellWithIdentifier("Cell")
                ?? UITableViewCell(style:.Default, reuseIdentifier: "Cell")

            cell.textLabel!.text = "\(i)"

            return cell
        }

        dataSource.titleForHeaderInSection = { (ds, section: Int) -> String in
            return dataSource.sectionAtIndex(section).model
        }
    }

    func skinCollectionViewDataSource(dataSource: CollectionViewSectionedDataSource<NumberSection>) {
        dataSource.cellFactory = { (_, cv, ip, i) in
            let cell = cv.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: ip) as! NumberCell

            cell.value!.text = "\(i)"

            return cell
        }

        dataSource.supplementaryViewFactory = { (dataSource, cv, kind, ip) in
            let section = cv.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Section", forIndexPath: ip) as! NumberSectionView

            section.value!.text = "\(dataSource.sectionAtIndex(ip.section).model)"

            return section
        }
    }

    override func viewWillDisappear(animated: Bool) {
        self.timer?.invalidate()
    }

    @IBAction func randomize() {
        generator.randomize()
        var values = generator.sections

        // useful for debugging
        if PartialUpdatesViewController.firstChange != nil {
            values = PartialUpdatesViewController.firstChange!
        }

        //print(values)

        sections.value = values
    }
}
