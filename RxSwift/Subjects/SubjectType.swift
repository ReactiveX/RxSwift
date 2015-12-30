//
//  SubjectType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents an object that is both an observable sequence as well as an observer.
*/
public protocol SubjectType : ObservableType {
    /**
    The type of the observer that represents this subject.
    
    Usually this type is type of subject itself, but it doesn't have to be.
    */
    typealias SubjectObserverType : ObserverType
    
    /**
    Returns observer interface for subject.
    
    - returns: Observer interface for subject.
    */
    func asObserver() -> SubjectObserverType
}