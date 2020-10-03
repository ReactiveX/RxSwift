//
//  ObservableConvertibleType+Infallible.swift
//  RxSwift
//
//  Created by Shai Mishali on 27/08/2020.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

extension ObservableConvertibleType {
    func asInfallible(onErrorJustReturn element: Element) -> Infallible<Element> {
        Infallible(self.asObservable().catchJustReturn(element))
    }

    func asInfallible(onErrorFallbackTo infallible: Infallible<Element>) -> Infallible<Element> {
        Infallible(self.asObservable().catch { _ in infallible.asObservable() })
    }

    func asInfallible(onErrorRecover: @escaping (Swift.Error) -> Infallible<Element>) -> Infallible<Element> {
        Infallible(asObservable().catch { onErrorRecover($0).asObservable() })
    }
}
