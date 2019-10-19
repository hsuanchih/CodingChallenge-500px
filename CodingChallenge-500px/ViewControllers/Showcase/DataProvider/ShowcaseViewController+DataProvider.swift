//
//  ]ShowcaseViewController+DataProvider.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/14.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation

extension ShowcaseViewController {
    
    // DataProvider
    // Synchronizes data updates from remote and local deletions to Core Data
    final class DataProvider {
        
        // Background serial queue used to enforce FIFO remote fetches & local deletes to prevent race conditions
        private lazy var dispatchQueue : DispatchQueue = {
            return DispatchQueue(label: String(format: "%@%@.Queue", String(describing: self), feature.rawValue), qos: .userInitiated)
        }()
        
        public private(set) var currentPage = 0
        public private(set) var totalPages = Int.max
        private let feature : ResourceParameter.Photos.Feature
        private let itemsPerPage : Int
        public init(feature: ResourceParameter.Photos.Feature, itemsPerPage: Int) {
            self.feature = feature
            self.itemsPerPage = itemsPerPage
        }
        
        public func delete(_ objects: [Photo]?) {
            dispatchQueue.async {
                if let objects = objects, !objects.isEmpty {
                    CoreDataStack.shared.delete(objects)
                }
                self.currentPage = 0
                self.totalPages = Int.max
            }
        }
        
        public func loadData(at indexPaths: [IndexPath]? = nil, onCompletion: ((Response<Photos>)->Void)? = nil) {
            dispatchQueue.async {
                var nextPage = 1
                switch (self.currentPage, indexPaths) {
                case (0, .none):
                    break
                case (1..<self.totalPages, .some(let indexPaths)) where indexPaths.first { $0.item == self.currentPage*self.itemsPerPage-15 } != nil:
                    nextPage = self.currentPage+1
                default:
                    return
                }
                Request(endPoint: .photos)
                    .resourceParameter(ResourceParameter.Photos.feature(self.feature))
                    .resourceParameter(ResourceParameter.Photos.page(nextPage))
                    .resourceParameter(ResourceParameter.Photos.rpp(self.itemsPerPage))
                    .resourceParameter(ResourceParameter.Photos.image_size(22))
                    .resourceParameter(ResourceParameter.Photos.image_size(4))
                    .fire { (response: Response<Photos>) in
                        if case let .success(result) = response {
                            self.currentPage = result.currentPage
                            self.totalPages = result.totalPages
                        }
                        onCompletion?(response)
                }
            }
        }
    }
}
