//
//  ImageService.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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
    func imageFromURL(URL: NSURL) -> Observable<DownloadableImage>
}

class DefaultImageService: ImageService {

    static let sharedImageService = DefaultImageService() // Singleton

    let $: Dependencies = Dependencies.sharedDependencies

    // 1st level cache
    private let _imageCache = NSCache()

    // 2nd level cache
    private let _imageDataCache = NSCache()

    let loadingImage = ActivityIndicator()
    
    private init() {
        // cost is approx memory usage
        _imageDataCache.totalCostLimit = 10 * MB
        
        _imageCache.countLimit = 20
    }
    
    private func decodeImage(imageData: NSData) -> Observable<Image> {
        return Observable.just(imageData)
            .observeOn($.backgroundWorkScheduler)
            .map { data in
                guard let image = Image(data: data) else {
                    // some error
                    throw apiError("Decoding image error")
                }
                return image.forceLazyImageDecompression()
            }
    }
    
    private func _imageFromURL(URL: NSURL) -> Observable<Image> {
        return Observable.deferred {
                let maybeImage = self._imageCache.objectForKey(URL) as? Image

                let decodedImage: Observable<Image>
                
                // best case scenario, it's already decoded an in memory
                if let image = maybeImage {
                    decodedImage = Observable.just(image)
                }
                else {
                    let cachedData = self._imageDataCache.objectForKey(URL) as? NSData
                    
                    // does image data cache contain anything
                    if let cachedData = cachedData {
                        decodedImage = self.decodeImage(cachedData)
                    }
                    else {
                        // fetch from network
                        decodedImage = self.$.URLSession.rx_data(NSURLRequest(URL: URL))
                            .doOnNext { data in
                                self._imageDataCache.setObject(data, forKey: URL)
                            }
                            .flatMap(self.decodeImage)
                            .trackActivity(self.loadingImage)
                    }
                }
                
                return decodedImage.doOnNext { image in
                    self._imageCache.setObject(image, forKey: URL)
                }
            }
    }

    /**
    Service that tries to download image from URL.
     
    In case there were some problems with network connectivity and image wasn't downloaded, automatic retry will be fired when networks becomes
    available.
     
    After image is sucessfully downloaded, sequence is completed.
    */
    func imageFromURL(URL: NSURL) -> Observable<DownloadableImage> {
        return _imageFromURL(URL)
                .map { DownloadableImage.Content(image: $0) }
                .retryOnBecomesReachable(DownloadableImage.OfflinePlaceholder, reachabilityService: ReachabilityService.sharedReachabilityService)
                .startWith(.Content(image: Image()))
    }
}
