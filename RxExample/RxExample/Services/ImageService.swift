//
//  ImageService.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

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
	
    // 1st level cache
    let imageCache = NSCache()
    
    // 2nd level cache
    let imageDataCache = NSCache()
    
    private init() {
        // cost is approx memory usage
        self.imageDataCache.totalCostLimit = 10 * MB
        
        self.imageCache.countLimit = 20
    }
    
    func decodeImage(imageData: NSData) -> Observable<Image> {
        return just(imageData)
            .observeOn($.backgroundWorkScheduler)
            .map { data in
                guard let image = Image(data: data) else {
                    // some error
                    throw apiError("Decoding image error")
                }
                return image
            }
            .observeOn($.mainScheduler)
    }
    
    func imageFromURL(URL: NSURL) -> Observable<Image> {
        return deferred {
            let maybeImage = self.imageCache.objectForKey(URL) as? Image
            
            let decodedImage: Observable<Image>
            
            // best case scenario, it's already decoded an in memory
            if let image = maybeImage {
                decodedImage = just(image)
            }
            else {
                let cachedData = self.imageDataCache.objectForKey(URL) as? NSData
                
                // does image data cache contain anything
                if let cachedData = cachedData {
                    decodedImage = self.decodeImage(cachedData)
                }
                else {
                    // fetch from network
                    decodedImage = self.$.URLSession.rx_data(NSURLRequest(URL: URL))
                        .doOn(onNext: { data in
                            self.imageDataCache.setObject(data, forKey: URL)
                        })
                        .flatMap(self.decodeImage)
                }
            }
            
            return decodedImage.doOn(onNext: { image in
                self.imageCache.setObject(image, forKey: URL)
            })
        }.observeOn($.mainScheduler)
    }
}
