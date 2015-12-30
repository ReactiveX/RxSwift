//
//  Wireframe.swift
//  Example
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

enum RetryResult {
    case Retry
    case Cancel
}

protocol Wireframe {
    func openURL(URL: NSURL)
    func promptFor<Action: CustomStringConvertible>(message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>
}


class DefaultWireframe: Wireframe {
    static let sharedInstance = DefaultWireframe()

    func openURL(URL: NSURL) {
        #if os(iOS)
            UIApplication.sharedApplication().openURL(URL)
        #elseif os(OSX)
            NSWorkspace.sharedWorkspace().openURL(URL)
        #endif
    }

    static func presentAlert(message: String) {
        #if os(iOS)
            let alertView = UIAlertView(
                title: "RxExample",
                message: message,
                delegate: nil,
                cancelButtonTitle: "OK"
            )

            alertView.show()
        #endif
    }

    func promptFor<Action : CustomStringConvertible>(message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        #if os(iOS)
        return Observable.create { observer in
            let alertView = UIAlertView(
                title: "RxExample",
                message: message,
                delegate: nil,
                cancelButtonTitle: cancelAction.description
            )

            for action in actions {
                alertView.addButtonWithTitle(action.description)
            }

            alertView.show()

            observer.on(.Next(alertView))

            return AnonymousDisposable {
                alertView.dismissWithClickedButtonIndex(-1, animated: true)
            }
        }.flatMap { (alertView: UIAlertView) -> Observable<Action> in
            return alertView.rx_didDismissWithButtonIndex.flatMap { index -> Observable<Action> in
                if index < 0 {
                    return Observable.empty()
                }

                if index == 0 {
                    return Observable.just(cancelAction)
                }

                return Observable.just(actions[index - 1])
            }
        }
        #elseif os(OSX)
            return Observable.error(NSError(domain: "Unimplemented", code: -1, userInfo: nil))
        #endif
    }
}


extension RetryResult : CustomStringConvertible {
    var description: String {
        switch self {
        case .Retry:
            return "Retry"
        case .Cancel:
            return "Cancel"
        }
    }
}