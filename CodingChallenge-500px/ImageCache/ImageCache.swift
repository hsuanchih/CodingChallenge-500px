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
extension String {
    fileprivate var uniqueIdentifier : Self? {
        return addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
}

// MARK: ImageCache
// ImageCache loads image given its url and caches the image locally to expedite access.
// Image loads from remote only if it doesn't already exist in the local store.
struct ImageCache {
    
    public enum Format : String {
        case jpeg
        case png
    }
    
    public enum `Error` : Swift.Error {
        case urlStringInvalid
        case localImageDataInvalid
        case remoteImageDataInvalid
        case filenameInvalid
    }
    
    public static func image(with urlString: String?, format: Format = .png, _ onCompletion: ((Response<UIImage>)->Void)? = nil) {
        guard let urlString = urlString, !urlString.isEmpty else {
            onCompletion?(Response.failure(Error.urlStringInvalid))
            return
        }
        if let filename = urlString.uniqueIdentifier?.appendingFormat(".%@", format.rawValue) {
            PersistentStore.retrieveData(file: filename, from: .cache) {
                switch $0 {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        onCompletion?(Response.success(image))
                    } else {
                        onCompletion?(Response.failure(Error.localImageDataInvalid))
                    }
                case.failure(_):
                    do {
                        if let url = URL(string: urlString), let image = UIImage(data: try Data(contentsOf: url)) {
                            onCompletion?(Response.success(image))
                            if let imageData = format == .png ? image.pngData() : image.jpegData(compressionQuality: 1) {
                                PersistentStore.save(data: imageData, to: filename, in: .cache)
                            }
                        } else {
                            onCompletion?(Response.failure(Error.remoteImageDataInvalid))
                        }
                    } catch {
                        onCompletion?(Response.failure(Error.remoteImageDataInvalid))
                    }
                }
            }
        } else {
            onCompletion?(Response.failure(Error.filenameInvalid))
        }
    }
}
