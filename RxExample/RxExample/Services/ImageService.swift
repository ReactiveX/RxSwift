//
//  ImageService.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif 

protocol ImageService {
    func imageFromURL(_ url: URL, reachabilityService: ReachabilityService) -> Observable<DownloadableImage>
}

class DefaultImageService: ImageService {

    static let sharedImageService = DefaultImageService() // Singleton

    let `$`: Dependencies = Dependencies.sharedDependencies

    // 1st level cache
    private let _imageCache = NSCache<AnyObject, AnyObject>()

    // 2nd level cache
    private let _imageDataCache = NSCache<AnyObject, AnyObject>()

    let loadingImage = ActivityIndicator()
    
    private init() {
        // cost is approx memory usage
        _imageDataCache.totalCostLimit = 10 * MB
        
        _imageCache.countLimit = 20
    }
    
    private func decodeImage(_ imageData: Data) -> Observable<Image> {
        return Observable.just(imageData)
            .observe(on:`$`.backgroundWorkScheduler)
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
                let maybeImage = self._imageCache.object(forKey: url as AnyObject) as? Image

                let decodedImage: Observable<Image>
                
                // best case scenario, it's already decoded an in memory
                if let image = maybeImage {
                    decodedImage = Observable.just(image)
                }
                else {
                    let cachedData = self._imageDataCache.object(forKey: url as AnyObject) as? Data
                    
                    // does image data cache contain anything
                    if let cachedData = cachedData {
                        decodedImage = self.decodeImage(cachedData)
                    }
                    else {
                        // fetch from network
                        decodedImage = self.`$`.URLSession.rx.data(request: URLRequest(url: url))
                            .do(onNext: { data in
                                self._imageDataCache.setObject(data as AnyObject, forKey: url as AnyObject)
                            })
                            .flatMap(self.decodeImage)
                            .trackActivity(self.loadingImage)
                    }
                }
                
                return decodedImage.do(onNext: { image in
                    self._imageCache.setObject(image, forKey: url as AnyObject)
                })
            }
    }

    /**
    Service that tries to download image from URL.
     
    In case there were some problems with network connectivity and image wasn't downloaded, automatic retry will be fired when networks becomes
    available.
     
    After image is successfully downloaded, sequence is completed.
    */
    func imageFromURL(_ url: URL, reachabilityService: ReachabilityService) -> Observable<DownloadableImage> {
        return _imageFromURL(url)
                .map { DownloadableImage.content(image: $0) }
                .retryOnBecomesReachable(DownloadableImage.offlinePlaceholder, reachabilityService: reachabilityService)
                .startWith(.content(image: Image()))
    }
}
