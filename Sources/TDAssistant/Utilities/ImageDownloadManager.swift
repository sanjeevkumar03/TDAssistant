//  ImageDownloadManager.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

typealias ImageDownloadCompletion = (_ imageURL: String, _ image: UIImage?) -> Void

/// This class is used to download the Image
class ImageDownloadManager: NSObject {

    // MARK: - Load Image
    /// This function is used to  load the image from URL
    /// - Parameters:
    ///   - imageURL: String
    ///   - completion: ImageDownloadCompletion
    func loadImage(imageURL: String, completion: ImageDownloadCompletion?) {
        guard let imgURL = URL(string: imageURL) else {
            return
        }

        let cache =  URLCache.shared
        let request = URLRequest(url: imgURL)
        DispatchQueue.global().async {
            if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                completion?(imageURL, image)
            } else {
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, _) in
                    if let data = data, let response = response, let image = UIImage(data: data) {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                        completion?(imageURL, image)
                    }
                }).resume()
            }
        }
    }
}
