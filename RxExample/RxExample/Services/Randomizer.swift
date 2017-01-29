//
//  Randomizer.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


typealias NumberSection = AnimatableSectionModel<String, Int>

let insertItems = true
let deleteItems = true
let moveItems = true
let reloadItems = true

let deleteSections = true
let insertSections = true
let explicitlyMoveSections = true
let reloadSections = true

class Randomizer {
    var sections: [NumberSection]
    
    var rng: PseudoRandomGenerator
    
    var unusedItems: [Int]
    var unusedSections: [String]
    
    init(rng: PseudoRandomGenerator, sections: [NumberSection]) {
        self.rng = rng
        self.sections = sections
        
        self.unusedSections = []
        self.unusedItems = []
    }
    
    func countTotalItemsInSections(_ sections: [NumberSection]) -> Int {
        return sections.reduce(0) { p, s in
            return p + s.items.count
        }
    }
    
    func randomize() {
        
        var nextUnusedSections = [String]()
        var nextUnusedItems = [Int]()
        
        let sectionCount = sections.count
        let itemCount = countTotalItemsInSections(sections)

        let startItemCount = itemCount + unusedItems.count
        let startSectionCount = sections.count + unusedSections.count
        
        // insert sections
        for section in unusedSections {
            let index = rng.get_random() % (sections.count + 1)
            if insertSections {
                sections.insert(NumberSection(model: section, items: []), at: index)
            }
            else {
               nextUnusedSections.append(section)
            }
        }

        // insert/reload items
        for unusedValue in unusedItems {
            let sectionIndex = rng.get_random() % sections.count
            let section = sections[sectionIndex]
            let itemCount = section.items.count
            
            // insert
            if rng.get_random() % 2 == 0 {
                let itemIndex = rng.get_random() % (itemCount + 1)
                if insertItems {
                    sections[sectionIndex].items.insert(unusedValue, at: itemIndex)
                }
                else {
                    nextUnusedItems.append(unusedValue)
                }
            }
            // update
            else {
                if itemCount == 0 {
                    sections[sectionIndex].items.insert(unusedValue, at: 0)
                    continue
                }
                
                let itemIndex = rng.get_random() % itemCount
                if reloadItems {
                    nextUnusedItems.append(sections[sectionIndex].items.remove(at: itemIndex))
                    sections[sectionIndex].items.insert(unusedValue, at: itemIndex)
                    
                }
                else {
                   nextUnusedItems.append(unusedValue)
                }
            }
        }
        
        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)
        
        let itemActionCount = itemCount / 7
        let sectionActionCount = sectionCount / 3
        
        // move items
        for _ in 0 ..< itemActionCount {
            if self.sections.count == 0 {
                continue
            }
            
            let sourceSectionIndex = rng.get_random() % self.sections.count
            let destinationSectionIndex = rng.get_random() % self.sections.count
            
            let sectionItemCount = sections[sourceSectionIndex].items.count
            
            if sectionItemCount == 0 {
                continue
            }
            
            let sourceItemIndex = rng.get_random() % sectionItemCount
            
            let nextRandom = rng.get_random()
            
            if moveItems {
                let item = sections[sourceSectionIndex].items.remove(at: sourceItemIndex)
                let targetItemIndex = nextRandom % (self.sections[destinationSectionIndex].items.count + 1)
                sections[destinationSectionIndex].items.insert(item, at: targetItemIndex)
            }
        }

        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)
        
        // delete items
        for _ in 0 ..< itemActionCount {
            if self.sections.count == 0 {
                continue
            }
            
            let sourceSectionIndex = rng.get_random() % self.sections.count
            
            let sectionItemCount = sections[sourceSectionIndex].items.count
            
            if sectionItemCount == 0 {
                continue
            }
            
            let sourceItemIndex = rng.get_random() % sectionItemCount
            
            if deleteItems {
                nextUnusedItems.append(sections[sourceSectionIndex].items.remove(at: sourceItemIndex))
            }
        }

        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)
        
        // move sections
        for _ in 0 ..< sectionActionCount {
            if sections.count == 0 {
                continue
            }
            
            let sectionIndex = rng.get_random() % sections.count
            let targetIndex = rng.get_random() % sections.count

            if explicitlyMoveSections {
                let section = sections.remove(at: sectionIndex)
                sections.insert(section, at: targetIndex)
            }
        }

        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)
        
        // delete sections 
        for _ in 0 ..< sectionActionCount {
            if sections.count == 0 {
                continue
            }
            
            let sectionIndex = rng.get_random() % sections.count
            
            if deleteSections {
                let section = sections.remove(at: sectionIndex)
                
                for item in section.items {
                    nextUnusedItems.append(item)
                }

                nextUnusedSections.append(section.model)
            }
        }

        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)
        
        unusedSections = nextUnusedSections
        unusedItems = nextUnusedItems
    }
}
