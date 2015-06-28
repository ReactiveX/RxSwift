//
//  TableViewPartialUpdatesViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import CoreData



class TableViewPartialUpdatesViewController : ViewController, UITableViewDelegate {
    @IBOutlet weak var reloadTableViewOutlet: UITableView!
    @IBOutlet weak var partialUpdatesTableViewOutlet: UITableView!
    
    var moc: NSManagedObjectContext!
    var child: NSManagedObjectContext!
    
    static let initialValue: [HashableSectionModel<String, Int>] = [
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
    
    
    static let firstChange: [HashableSectionModel<String, Int>]? = nil
    
    var generator = Randomizer(rng: PseudoRandomGenerator(4, 3), sections: initialValue)

    /*var generator = Randomizer(rng: PseudoRandomGenerator(4, 3), sections: [
        NumberSection(model: "1", items: [1111]),
        NumberSection(model: "2", items: [2222]),
    ])
    */
    var sections = Variable([NumberSection]())
    
    let disposeBag = DisposeBag()
    
    func skinDataSource(dataSource: RxTableViewSectionedDataSource<NumberSection>) {
        dataSource.cellFactory = { (tv: UITableView, ip, s, i) in
            let cell = tv.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
                ?? UITableViewCell(style:.Default, reuseIdentifier: "Cell")
            
            cell.textLabel!.text = "\(i)"
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { [unowned dataSource] (section: Int) -> String in
            return dataSource.sectionAtIndex(section).model
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.sections.next(generator.sections)
        
        let animatedDataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        let reloadDataSource = RxTableViewSectionedReloadDataSource<NumberSection>()
        
        skinDataSource(animatedDataSource)
        skinDataSource(reloadDataSource)
        
        let newSections = self.sections >- skip(1)
        
        let initialState = [Changeset.initialValue(self.sections.value)]
        
        // reactive data sources
        
        zip(self.sections, newSections) { (old, new) in
                return differentiate(old, new)
            }
            >- startWith(initialState)
            >- partialUpdatesTableViewOutlet.rx_subscribeWithReactiveDataSource(animatedDataSource)
            >- disposeBag.addDisposable

        self.sections
            >- reloadTableViewOutlet.rx_subscribeWithReactiveDataSource(reloadDataSource)
            >- disposeBag.addDisposable
    }
    
    @IBAction func randomize() {
        generator.randomize()
        var values = generator.sections
       
        // useful for debugging
        if TableViewPartialUpdatesViewController.firstChange != nil {
            values = TableViewPartialUpdatesViewController.firstChange!
        }
        
        sections.next(values)
    }
}