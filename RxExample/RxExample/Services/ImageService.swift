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

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif 

protocol ImageService {
    func imageFromURL(URL: NSURL) -> Observable<Image>
}

class DefaultImageService: ImageService {
	
	static let sharedImageService = DefaultImageService() // Singleton
	
	let $: Dependencies = Dependencies.sharedDependencies
	
    // 1rst level cache
    let imageCache = NSCache()
    
    // 2nd level cache
    let imageDataCache = NSCache()
    
    private init() {
        // cost is approx memory usage
        self.imageDataCache.totalCostLimit = 10 * MB
        
        self.imageCache.countLimit = 20
    }
    
    func decodeImage(imageData: Observable<NSData>) -> Observable<Image> {
        return imageData >- observeSingleOn($.backgroundWorkScheduler) >- mapOrDie { data in
            let maybeImage = Image(data: data)
            
            if maybeImage == nil {
                // some error
                return failure(apiError("Decoding image error"))
            }
            
            let image = maybeImage!
            
            return success(image)
        } >- observeSingleOn($.mainScheduler)
    }
    
    func imageFromURL(URL: NSURL) -> Observable<Image> {
        return defer {
            let maybeImage = self.imageDataCache.objectForKey(URL) as? Image
            
            let decodedImage: Observable<Image>
            
            // best case scenario, it's already decoded an in memory
            if let image = maybeImage {
                decodedImage = returnElement(image)
            }
            else {
                let cachedData = self.imageDataCache.objectForKey(URL) as? NSData
                
                // does image data cache contain anything
                if let cachedData = cachedData {
                    decodedImage = returnElement(cachedData) >- self.decodeImage
                }
                else {
                    // fetch from network
                    decodedImage = self.$.URLSession.rx_data(NSURLRequest(URL: URL)) >- doOnNext { data in
                        self.imageDataCache.setObject(data, forKey: URL)
                    } >- self.decodeImage
                }
            }
            
            return decodedImage >- doOnNext { image in
                self.imageCache.setObject(image, forKey: URL)
            }
        }
    }
}
