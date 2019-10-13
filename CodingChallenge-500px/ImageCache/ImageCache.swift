//
//  ImageCache.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/12.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit


// This method is used to extract an unique idenifier from an image's url, and is used as the
// file name with which to store the image data. The implementation may vary, and percent encoding
// is guaranteed to yield unique idenfifier for each differnt url.
// In the case of 500px image urls, assuming trailing sig=<uniqueID> can be used to uniquely idenfity
// each image, we extract only this part of the url and use it instead as it gives a much shorted file name.
extension String {
    fileprivate var uniqueIdentifier : Self? {
        guard let id = split(separator: "=").last else { return nil }
        return Self(id)
    }
}

// MARK: ImageCache
// ImageCache loads image given its url and caches the image locally to expedite access.
// Image loads from remote only if it doesn't already exist in the local store.
struct ImageCache {
    
    public static func image(with urlString: String?, format: Format = .jpeg, _ onCompletion: ((UIImage?)->Void)? = nil) {
        guard let urlString = urlString else {
            onCompletion?(nil)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let filename = urlString.uniqueIdentifier?.appendingFormat(".%@", format.rawValue) else {
                    onCompletion?(nil)
                    return
                }
                if let data = try PersistentStore.retrieveData(file: filename, from: .cache) {
                    onCompletion?(UIImage(data: data))
                    return
                }
                guard let url = URL(string: urlString), let image = UIImage(data: try Data(contentsOf: url)) else {
                    onCompletion?(nil)
                    return
                }
                onCompletion?(image)
                if let imageData = format == .png ? image.pngData() : image.jpegData(compressionQuality: 1) {
                    try PersistentStore.save(
                        data: imageData,
                        to: filename,
                        in: .cache
                    )
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension ImageCache {
    public enum Format : String {
        case jpeg
        case png
    }
}
