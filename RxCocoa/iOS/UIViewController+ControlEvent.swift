//
//  UIViewController+ControlEvent.swift
//  RxCocoa
//
//  Created by SIARHEI LUKYANAU on 05.03.2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Reactive where Base: UIViewController {
    public var loadView: ControlEvent<()> {
        return controlEventForVoidReturningSelector(#selector(Base.loadView))
    }
    
    public var loadViewIfNeeded: ControlEvent<()> {
        return controlEventForVoidReturningSelector(#selector(Base.loadViewIfNeeded))
    }
    
    public var viewDidLoad: ControlEvent<()> {
        return controlEventForVoidReturningSelector(#selector(Base.viewDidLoad))
    }
    
    public var viewWillAppear: ControlEvent<Bool> {
        return controlEventForBoolReturningSelector(#selector(Base.viewWillAppear))
    }
    
    public var viewWillLayoutSubviews: ControlEvent<()> {
        return controlEventForVoidReturningSelector(#selector(Base.viewWillLayoutSubviews))
    }
    
    public var viewDidLayoutSubviews: ControlEvent<()> {
        return controlEventForVoidReturningSelector(#selector(Base.viewDidLayoutSubviews))
    }
    
    public var viewDidAppear: ControlEvent<Bool> {
        return controlEventForBoolReturningSelector(#selector(Base.viewDidAppear))
    }
    
    public var viewWillDisappear: ControlEvent<Bool> {
        return controlEventForBoolReturningSelector(#selector(Base.viewWillDisappear))
    }
    
    public var viewDidDisappear: ControlEvent<Bool> {
        return controlEventForBoolReturningSelector(#selector(Base.viewDidDisappear))
    }
    
    private func controlEventForVoidReturningSelector(_ sel: Selector) -> ControlEvent<()> {
        let source = self.methodInvoked(sel).map { _ in return () }
        return ControlEvent(events: source)
    }
    
    private func controlEventForBoolReturningSelector(_ sel: Selector) -> ControlEvent<Bool> {
        let source = self.methodInvoked(sel).map { args in return (args.first as? Bool) == true }
        return ControlEvent(events: source)
    }
}
