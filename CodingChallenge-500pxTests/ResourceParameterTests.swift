//
//  ResourceParameterTests.swift
//  CodingChallenge-500pxTests
//
//  Created by Hsuan-Chih Chuang on 2019/10/21.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import XCTest
@testable import CodingChallenge_500px

class ResourceParameterTests: XCTestCase {
    
    var request : Request<Photo> = Request(endPoint: .photos)
    lazy var allowedCharactersInEncoding : CharacterSet = {
        var charSet = CharacterSet.alphanumerics
        charSet.insert(charactersIn: "_=")
        return charSet
    }()
    
    func testParamFeature() {
        XCTAssert(request
            .resourceParameter(ResourceParameter.Photos.feature(.popular))
            .constructUrlRequest.url!.absoluteString.contains("feature=popular")
        )
    }
    
    func testParamPageNumber() {
        XCTAssert(request
            .resourceParameter(ResourceParameter.Photos.page(3))
            .constructUrlRequest.url!.absoluteString.contains("page=3")
        )
    }
    
    func testParamItemsPerPage() {
        XCTAssert(request
            .resourceParameter(ResourceParameter.Photos.rpp(10))
            .constructUrlRequest.url!.absoluteString.contains("rpp=10")
        )
    }
    
    func testParamImageSize() {
        XCTAssert(request
            .resourceParameter(ResourceParameter.Photos.image_size(20))
            .constructUrlRequest.url!.absoluteString.contains(
                "image_size[]=20".addingPercentEncoding(withAllowedCharacters: allowedCharactersInEncoding)!
            )
        )
    }
}
