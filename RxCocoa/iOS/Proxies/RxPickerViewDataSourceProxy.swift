//
//  RxPickerViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Sergey Shulga on 05/07/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

    import UIKit
#if !RX_NO_MODULE
    import RxSwift
#endif

fileprivate let pickerViewDataSourceNotSet = PickerViewDataSourceNotSet()

final fileprivate class PickerViewDataSourceNotSet: NSObject, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
}

/// For more information take a look at `DelegateProxyType`.
public class RxPickerViewDataSourceProxy
    : DelegateProxy<UIPickerView, UIPickerViewDataSource>
    , DelegateProxyType
    , UIPickerViewDataSource {

    /// Typed parent object.
    public weak private(set) var pickerView: UIPickerView?

    /// - parameter parentObject: Parent object for delegate proxy.
    public init(parentObject: ParentObject) {
        self.pickerView = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxPickerViewDataSourceProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxPickerViewDataSourceProxy(parentObject: $0) }
    }

    private weak var _requiredMethodsDataSource: UIPickerViewDataSource? = pickerViewDataSourceNotSet

    // MARK: UIPickerViewDataSource

    /// Required delegate method implementation.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return (_requiredMethodsDataSource ?? pickerViewDataSourceNotSet).numberOfComponents(in: pickerView)
    }

    /// Required delegate method implementation.
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (_requiredMethodsDataSource ?? pickerViewDataSourceNotSet).pickerView(pickerView, numberOfRowsInComponent: component)
    }
    
    // MARK: proxy
    
    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: UIPickerViewDataSource?, to object: UIPickerView) {
        object.dataSource = delegate
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegate(for object: UIPickerView) -> UIPickerViewDataSource? {
        return object.dataSource
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public override func setForwardToDelegate(_ forwardToDelegate: UIPickerViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? pickerViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
