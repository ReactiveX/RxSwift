//
//  ImageService.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Rx
import RxCocoa

protocol ImageService {
    func imageFromURL(URL: NSURL) -> Observable<Result<UIImage>>
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
    
    func decodeImage(imageData: Observable<Result<NSData>>) -> Observable<Result<UIImage>> {
        return imageData >- observeSingleOn($.imageDecodeScheduler) >- map { maybeData in
            return maybeData >== { data in
                let maybeImage = UIImage(data: data)
                
                if maybeImage == nil {
                    // some error
                    return .Error(apiError("Decoding image error"))
                }
                
                let image = maybeImage!
                
                return success(image)
            }
        } >- observeSingleOn($.callbackScheduler)
    }
    
    func imageFromURL(URL: NSURL) -> Observable<Result<UIImage>> {
        let maybeImage = self.imageDataCache.objectForKey(URL) as? UIImage
        
        let decodedImage: Observable<Result<UIImage>>
        
        // best case scenario, it's already decoded an in memory
        if let image = maybeImage {
            decodedImage = returnElement(success(image))
        }
        else {
            let cachedData = self.imageDataCache.objectForKey(URL) as? NSData
            
            // does image data cache contain anything
            if let cachedData = cachedData {
                decodedImage = returnElement(success(cachedData)) >- decodeImage
            }
            else {
                // fetch from network
                decodedImage = $.URLSession.rx_observableDataRequest(NSURLRequest(URL: URL)) >- doOnNext { maybeData in
                    _ = maybeData >== { data in
                        self.imageDataCache.setObject(data, forKey: URL)
                    }
                } >- decodeImage
            }
        }
        
        return decodedImage >- doOnNext { maybeImage in
            if let image = maybeImage.value {
                self.imageCache.setObject(image, forKey: URL)
            }
        }
    }
}
