//
//  ImagePickerController.swift
//  RxExample
//
//  Created by Segii Shulga on 1/5/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
   import RxSwift
   import RxCocoa
#endif

struct ImagePickerConfiguration {
   let soruceType:UIImagePickerControllerSourceType
   let allowsEditing:Bool
}

class ImagePickerController: ViewController {

   @IBOutlet var imageView: UIImageView!
   @IBOutlet var cameraButton: UIButton!
   @IBOutlet var galleryButton: UIButton!
   @IBOutlet var cropButton: UIButton!
   
   let imagePickerController = UIImagePickerController()
   
   private(set) lazy var showImagePickerObserver:AnyObserver<ImagePickerConfiguration> = {
      return AnyObserver { [weak self] event in
         switch event {
         case .Next(let configuration):
            guard let strong = self else {return}
            strong.imagePickerController.sourceType = configuration.soruceType
            strong.imagePickerController.allowsEditing = configuration.allowsEditing
            strong.presentViewController(strong.imagePickerController,
               animated: true,
               completion: nil)
         default:
            break;
         }
      }
   }()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      imagePickerController
         .rx_didFinishPickingMediaWithInfo
         .filter({[weak self] _ in return (self?.imagePickerController.allowsEditing ?? false) == false})
         .map { (info) in
            return info[UIImagePickerControllerOriginalImage] as? UIImage
         }
         .bindTo(imageView.rx_image)
         .addDisposableTo(disposeBag)
      
      imagePickerController
         .rx_didFinishPickingMediaWithInfo
         .filter({[weak self] _ in return (self?.imagePickerController.allowsEditing ?? false)})
         .map { (info) in
            return info[UIImagePickerControllerEditedImage] as? UIImage
         }
         .bindTo(imageView.rx_image)
         .addDisposableTo(disposeBag)
      
      
      cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
      
      cameraButton.rx_tap
         .map{ _ in ImagePickerConfiguration(soruceType: .Camera, allowsEditing: false)}
         .bindTo(showImagePickerObserver)
         .addDisposableTo(disposeBag)
      
      galleryButton.rx_tap
         .map{ _ in ImagePickerConfiguration(soruceType: .PhotoLibrary, allowsEditing: false)}
         .bindTo(showImagePickerObserver)
         .addDisposableTo(disposeBag)
      
      cropButton.rx_tap
         .map({_ in ImagePickerConfiguration(soruceType: .PhotoLibrary, allowsEditing: true)})
         .bindTo(showImagePickerObserver)
         .addDisposableTo(disposeBag)
      
      let dismissPickerTrigger = Observable
         .of(imagePickerController.rx_didFinishPickingMediaWithInfo.map({_ in ()}),
            imagePickerController.rx_didCancel)
         .merge()
      
      dismissPickerTrigger
         .subscribeNext { [weak self] in
            self?.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
         }
         .addDisposableTo(disposeBag)
   }
   
}
