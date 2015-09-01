//
//  NSManagedObjectContext+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
//import CoreData
#if !RX_NO_MODULE
import RxSwift
#endif

/*
class FetchResultControllerSectionObserver: NSObject, NSFetchedResultsControllerDelegate, Disposable {
    typealias Observer = ObserverOf<[NSFetchedResultsSectionInfo]>

    let observer: Observer
    let frc: NSFetchedResultsController

    init(observer: Observer, frc: NSFetchedResultsController) {
        self.observer = observer
        self.frc = frc

        super.init()

        self.frc.delegate = self

        var error: NSError? = nil
        if !self.frc.performFetch(&error) {
            sendError(observer, error ?? UnknownError)
            return
        }

        sendNextElement()
    }

    func sendNextElement() {
        let sections = self.frc.sections as! [NSFetchedResultsSectionInfo]
        observer.on(.Next(sections))
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        sendNextElement()
    }

    func dispose() {
        self.frc.delegate = nil
    }
}

class FetchResultControllerEntityObserver: NSObject, NSFetchedResultsControllerDelegate, Disposable {
    typealias Observer = ObserverOf<[NSManagedObject]>

    let observer: Observer
    let frc: NSFetchedResultsController

    init(observer: Observer, frc: NSFetchedResultsController) {
        self.observer = observer
        self.frc = frc

        super.init()

        self.frc.delegate = self

        var error: NSError? = nil
        if !self.frc.performFetch(&error) {
            sendError(observer, error ?? UnknownError)
            return
        }

        sendNextElement()
    }

    func sendNextElement() {
        let entities = self.frc.fetchedObjects as! [NSManagedObject]

        observer.on(.Next(entities))
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        sendNextElement()
    }

    func dispose() {
        self.frc.delegate = nil
    }
}

class FetchResultControllerIncrementalObserver: NSObject, NSFetchedResultsControllerDelegate, Disposable {
    typealias Observer = ObserverOf<CoreDataEntityEvent>

    let observer: Observer
    let frc: NSFetchedResultsController

    init(observer: Observer, frc: NSFetchedResultsController) {
        self.observer = observer
        self.frc = frc

        super.init()

        self.frc.delegate = self

        var error: NSError? = nil
        if !self.frc.performFetch(&error) {
            sendError(observer, error ?? UnknownError)
            return
        }

        let sections = self.frc.sections as! [NSFetchedResultsSectionInfo]

        observer.on(.Next(.Snapshot(sections: sections)))
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        let event: CoreDataEntityEvent

        switch type {
        case .Insert:
            event = .ItemInserted(item: anObject as! NSManagedObject, newIndexPath: newIndexPath!)
        case .Delete:
            event = .ItemDeleted(withIndexPath: indexPath!)
        case .Move:
            event = .ItemMoved(item: anObject as! NSManagedObject, sourceIndexPath: indexPath!, destinationIndexPath: newIndexPath!)
        case .Update:
            event = .ItemUpdated(item: anObject as! NSManagedObject, atIndexPath: indexPath!)
        }

        observer.on(.Next(event))
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {

        let event: CoreDataEntityEvent

        switch type {
        case .Insert:
            event = .SectionInserted(section: sectionInfo, newIndex: sectionIndex)
        case .Delete:
            event = .SectionDeleted(withIndex: sectionIndex)
        case .Move:
            rxFatalError("Unknown event")
            event = .SectionInserted(section: sectionInfo, newIndex: -1)
        case .Update:
            event = .SectionUpdated(section: sectionInfo, atIndex: sectionIndex)
        }

        observer.on(.Next(event))
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        observer.on(.Next(.TransactionStarted))
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        observer.on(.Next(.TransactionEnded))
    }

    func dispose() {
        self.frc.delegate = nil
    }
}

extension NSManagedObjectContext {

    func rx_entitiesAndChanges(query: NSFetchRequest) -> Observable<CoreDataEntityEvent> {
        return rx_sectionsAndChanges(query, sectionNameKeyPath: nil)
    }

    func rx_sectionsAndChanges(query: NSFetchRequest, sectionNameKeyPath: String? = nil) -> Observable<CoreDataEntityEvent> {
        return AnonymousObservable { observer in
            let frc = NSFetchedResultsController(fetchRequest: query, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)

            let observerAdapter = FetchResultControllerIncrementalObserver(observer: observer, frc: frc)

            return AnonymousDisposable {
                observerAdapter.dispose()
            }
        }
    }

    func rx_entities(query: NSFetchRequest) -> Observable<[NSManagedObject]> {
        return AnonymousObservable { observer in
            let frc = NSFetchedResultsController(fetchRequest: query, managedObjectContext: self, sectionNameKeyPath: nil, cacheName: nil)

            let observerAdapter = FetchResultControllerEntityObserver(observer: observer, frc: frc)

            return AnonymousDisposable {
                observerAdapter.dispose()
            }
        }
    }

    func rx_sections(query: NSFetchRequest, sectionNameKeyPath: String) -> Observable<[NSFetchedResultsSectionInfo]> {
        return AnonymousObservable { observer in
            let frc = NSFetchedResultsController(fetchRequest: query, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)

            let observerAdapter = FetchResultControllerSectionObserver(observer: observer, frc: frc)

            return AnonymousDisposable {
                observerAdapter.dispose()
            }
        }
    }
}*/
