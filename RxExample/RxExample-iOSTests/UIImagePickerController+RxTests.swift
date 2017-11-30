//
//  UIImagePickerController+RxTests.swift
//  RxExample
//
//  Created by Segii Shulga on 1/6/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//



#if os(iOS)
    
import RxSwift
import RxCocoa
import XCTest
import UIKit
import RxExample_iOS

class UIImagePickerControllerTests: RxTest {
    
}

extension UIImagePickerControllerTests {
    
    func testDidFinishPickingMediaWithInfo() {
        var completed = false
        var info:[String:AnyObject]?
        
        let pickedInfo = [UIImagePickerControllerOriginalImage : UIImage()]
        
        autoreleasepool {
            let imagePickerController = UIImagePickerController()
            
            _ = imagePickerController.rx.didFinishPickingMediaWithInfo
                .subscribe(onNext: { (i) -> Void in
                    info = i
                }, onCompleted: {
                    completed = true
                })
            
            imagePickerController.delegate!
                .imagePickerController!(imagePickerController,didFinishPickingMediaWithInfo:pickedInfo)
            
            
        }
        
        XCTAssertTrue(info?[UIImagePickerControllerOriginalImage] === pickedInfo[UIImagePickerControllerOriginalImage])
        XCTAssertTrue(completed)
    }
    
    func testDidCancel() {
        var completed = false
        var canceled = false
        
        autoreleasepool {
            
            let imagePickerController = UIImagePickerController()
            
            _ = imagePickerController.rx.didCancel
                .subscribe(onNext: { (i) -> Void in
                        canceled = true
                    }, onCompleted: {
                        completed = true
                })
            imagePickerController.delegate!.imagePickerControllerDidCancel!(imagePickerController)
            
        }
        XCTAssertTrue(canceled)
        XCTAssertTrue(completed)
    }
    
}
    
#endif
