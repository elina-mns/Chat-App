//
//  UIImageView+ImageDownload.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-16.
//

import UIKit

private let cache = NSCache<NSString, NSData>()

extension UIImageView {
    //Load image async from internet
    
    func loadFromURL(photoUrl: URL, completion: ((UIImage?) -> Void)? = nil) {
        if let cachedData = cache.object(forKey: photoUrl.absoluteString as NSString),
           let image = UIImage(data: cachedData as Data) {
            DispatchQueue.main.async {
                self.image = image
                completion?(image)
            }
            return
        }
        let request = URLRequest(url: photoUrl);
        let session = URLSession.shared
        let datatask = session.dataTask(with: request) { (data, response, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                completion?(nil)
                return
            }
            guard let data = data else {
                completion?(nil)
                return
            }
            cache.setObject(data as NSData, forKey: photoUrl.absoluteString as NSString)
            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else {
                    completion?(nil)
                    return
                }
                self.image = image
                completion?(image)
            }
        }
        datatask.resume()
    }


}
