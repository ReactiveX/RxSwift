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
        var info:[UIImagePickerController.InfoKey:AnyObject]?
        
        let pickedInfo = [UIImagePickerController.InfoKey.originalImage : UIImage()]
        
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
        
        XCTAssertTrue(info?[UIImagePickerController.InfoKey.originalImage] === pickedInfo[UIImagePickerController.InfoKey.originalImage])
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
    
    func testOriginalImage() {
        var completed = false
        var originalImage: UIImage?
        
        let pickedInfo = [UIImagePickerController.InfoKey.originalImage : UIImage()]
        
        autoreleasepool {
            
            let imagePickerController = UIImagePickerController()
            
            _ = imagePickerController.rx.originalImage
                .subscribe(onNext: { image in
                    originalImage = image
                }, onCompleted: {
                    completed = true
                })
            
            imagePickerController.delegate!
                .imagePickerController!(imagePickerController,didFinishPickingMediaWithInfo: pickedInfo)
            
            
        }
        
        XCTAssertEqual(originalImage, pickedInfo[UIImagePickerController.InfoKey.originalImage])
        XCTAssertTrue(completed)
    }
    
    func testEditedImage() {
        var completed = false
        var editedImage: UIImage?
        
        let pickedInfo = [UIImagePickerController.InfoKey.editedImage : UIImage()]
        
        autoreleasepool {
            
            let imagePickerController = UIImagePickerController()
            
            _ = imagePickerController.rx.editedImage
                .subscribe(onNext: { image in
                    editedImage = image
                }, onCompleted: {
                    completed = true
                })
            
            imagePickerController.delegate!
                .imagePickerController!(imagePickerController,didFinishPickingMediaWithInfo: pickedInfo)
            
            
        }
        
        XCTAssertEqual(editedImage, pickedInfo[UIImagePickerController.InfoKey.editedImage])
        XCTAssertTrue(completed)
    }
    
}
    
#endif
