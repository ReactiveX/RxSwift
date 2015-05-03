//
//  ImageService.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ImageService {
    func imageFromURL(URL: NSURL) -> Observable<UIImage>
}

class DefaultImageService: ImageService {
    typealias Dependencies = (
        URLSession: NSURLSession,
        imageDecodeScheduler: ImmediateScheduler,
        callbackScheduler: ImmediateScheduler
    )
    
    var $: Dependencies
    
    // 1rst level cache
    let imageCache = NSCache()
    
    // 2nd level cache
    let imageDataCache = NSCache()
    
    init($: Dependencies) {
        self.$ = $
        
        // cost is approx memory usage
        self.imageDataCache.totalCostLimit = 10 * MB
        
        self.imageCache.countLimit = 20
    }
    
    func decodeImage(imageData: Observable<NSData>) -> Observable<UIImage> {
        return imageData >- observeSingleOn($.imageDecodeScheduler) >- mapOrDie { data in
            let maybeImage = UIImage(data: data)
            
            if maybeImage == nil {
                // some error
                return .Error(apiError("Decoding image error"))
            }
            
            let image = maybeImage!
            
            return success(image)
        } >- observeSingleOn($.callbackScheduler)
    }
    
    func imageFromURL(URL: NSURL) -> Observable<UIImage> {
        let maybeImage = self.imageDataCache.objectForKey(URL) as? UIImage
        
        let decodedImage: Observable<UIImage>
        
        // best case scenario, it's already decoded an in memory
        if let image = maybeImage {
            decodedImage = returnElement(image)
        }
        else {
            let cachedData = self.imageDataCache.objectForKey(URL) as? NSData
            
            // does image data cache contain anything
            if let cachedData = cachedData {
                decodedImage = returnElement(cachedData) >- decodeImage
            }
            else {
                // fetch from network
                decodedImage = $.URLSession.rx_data(NSURLRequest(URL: URL)) >- doOnNext { data in
                    self.imageDataCache.setObject(data, forKey: URL)
                } >- decodeImage
            }
        }
        
        return decodedImage >- doOnNext { image in
            self.imageCache.setObject(image, forKey: URL)
        }
    }
}
