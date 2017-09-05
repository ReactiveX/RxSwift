//
//  NSPopUpButton+Rx.swift
//  RxSwift-iOS
//
//  Created by Florent Pillet on 05/09/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)
	
#if !RX_NO_MODULE
	import RxSwift
#endif
	import Cocoa
	
	extension Reactive where Base: NSPopUpButton {
		
		/// Bidirectional reactive wrapper for `indexOfSelectedItem` property.
		public var selectedItemIndex: ControlProperty<Int> {
			return NSPopUpButton.rx.value(
				self.base,
				getter: { control in
					control.indexOfSelectedItem
				},
				setter: { control, value in
					control.selectItem(at: value)
				}
			)
		}
		
		/// Bidirectional reactive wrapper for `selectedItem` property.
		public var selectedItem: ControlProperty<NSMenuItem?> {
			return NSPopUpButton.rx.value(
				self.base,
				getter: { control in
					control.selectedItem
			},
				setter: { control, value in
					control.select(value)
			}
			)
		}

		/// Bidirectional reactive wrapper for `selectedItemTitle` property.
		public var selectedItemTitle: ControlProperty<String?> {
			return NSPopUpButton.rx.value(
				self.base,
				getter: { control in
					control.titleOfSelectedItem
			},
				setter: { control, value in
					if let value = value {
						control.selectItem(withTitle: value)
					} else {
						control.select(nil)
					}
			}
			)
		}

		/// Bidirectional reactive wrapper for item selection with tag
		public var selectedItemTag: ControlProperty<Int?> {
			return NSPopUpButton.rx.value(
				self.base,
				getter: { control in
					control.selectedItem?.tag
			},
				setter: { control, value in
					if let value = value {
						control.selectItem(withTag: value)
					} else {
						control.select(nil)
					}
			}
			)
		}
		
		/// Bindable sink for simple menu items property.
		///
		public func menuItems() -> UIBindingObserver<Base, [String]> {
			return UIBindingObserver(UIElement: self.base) { control, array in
				control.removeAllItems()
				control.addItems(withTitles: array)
			}
		}

		/// Bindable sink for menu items with tag property. Each entry is a tuple `(String,Int)`
		/// representing the item title and its associated tag. Caller is responsible for
		/// guaranteeing tag uniqueness.
		///
		public func menuItemsWithTags() -> UIBindingObserver<Base, [(String,Int)]> {
			return UIBindingObserver(UIElement: self.base) { control, array in
				control.removeAllItems()
				control.addItems(withTitles: array.map { $0.0 })
				for (menuItem, newItem) in zip(control.itemArray, array) {
					menuItem.tag = newItem.1
				}
			}
		}
}
	
#endif
