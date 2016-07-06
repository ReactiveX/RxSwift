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
    func imageFromURL(_ url: URL, reachabilityService: ReachabilityService) -> Observable<DownloadableImage>
}

class DefaultImageService: ImageService {

    static let sharedImageService = DefaultImageService() // Singleton

    let $: Dependencies = Dependencies.sharedDependencies

    // 1st level cache
    private let _imageCache = Cache<AnyObject, AnyObject>()

    // 2nd level cache
    private let _imageDataCache = Cache<AnyObject, AnyObject>()

    let loadingImage = ActivityIndicator()
    
    private init() {
        // cost is approx memory usage
        _imageDataCache.totalCostLimit = 10 * MB
        
        _imageCache.countLimit = 20
    }
    
    private func decodeImage(_ imageData: Data) -> Observable<Image> {
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
    
    private func _imageFromURL(_ url: URL) -> Observable<Image> {
        return Observable.deferred {
                let maybeImage = self._imageCache.object(forKey: url) as? Image

                let decodedImage: Observable<Image>
                
                // best case scenario, it's already decoded an in memory
                if let image = maybeImage {
                    decodedImage = Observable.just(image)
                }
                else {
                    let cachedData = self._imageDataCache.object(forKey: url) as? Data
                    
                    // does image data cache contain anything
                    if let cachedData = cachedData {
                        decodedImage = self.decodeImage(cachedData)
                    }
                    else {
                        // fetch from network
                        decodedImage = self.$.URLSession.rx_data(URLRequest(url: url))
                            .doOnNext { data in
                                self._imageDataCache.setObject(data, forKey: url)
                            }
                            .flatMap(self.decodeImage)
                            .trackActivity(self.loadingImage)
                    }
                }
                
                return decodedImage.doOnNext { image in
                    self._imageCache.setObject(image, forKey: url)
                }
            }
    }

    /**
    Service that tries to download image from URL.
     
    In case there were some problems with network connectivity and image wasn't downloaded, automatic retry will be fired when networks becomes
    available.
     
    After image is sucessfully downloaded, sequence is completed.
    */
    func imageFromURL(_ url: URL, reachabilityService: ReachabilityService) -> Observable<DownloadableImage> {
        return _imageFromURL(url)
                .map { DownloadableImage.content(image: $0) }
                .retryOnBecomesReachable(DownloadableImage.offlinePlaceholder, reachabilityService: reachabilityService)
                .startWith(.content(image: Image()))
    }
}
