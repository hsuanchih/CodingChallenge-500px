//
//  PersistentStoreTests.swift
//  CodingChallenge-500pxTests
//
//  Created by Hsuan-Chih Chuang on 2019/10/21.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import XCTest
@testable import CodingChallenge_500px

class PersistentStoreTests: XCTestCase {

    let imageBubble = "bubble.jpg", imageTunnel = "tunnel.jpg"
    let fileToSave = "persistent_store_test.jpg"
    var data : Data!
    
    override class func setUp() {
        super.setUp()
        PersistentStore.clear(.cache)
    }
    
    override func setUp() {
        super.setUp()
        let file = imageBubble.fileDescription
        data = TestResources.contentsOf(file: file.name, type: file.ext)
        PersistentStore.save(data: data, to: fileToSave, in: .cache)
    }
    
    override func tearDown() {
        PersistentStore.clear(.cache)
        super.tearDown()
    }
    
    func testSynchronizedRead() {
        let expect = expectation(description: "\(#function)")
        PersistentStore.retrieveData(file: fileToSave, from: .cache) {
            switch $0 {
            case .success(let data):
                XCTAssertEqual(data, self.data)
                expect.fulfill()
            case .failure(let error):
                XCTAssert(false, error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testConcurrentRead() {
        let expect = expectation(description: "\(#function)"), dispatchGroup = DispatchGroup()
        for _ in 0..<10 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                PersistentStore.retrieveData(file: self.fileToSave, from: .cache) {
                    switch $0 {
                    case .success(let data):
                        XCTAssertEqual(data, self.data)
                    case .failure(let error):
                        XCTAssert(false, error.localizedDescription)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) { expect.fulfill() }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testExclusiveWrite() {
        let expect = expectation(description: "\(#function)")
        
        let file = self.imageTunnel.fileDescription
        self.data = TestResources.contentsOf(file: file.name, type: file.ext)
        PersistentStore.save(data: self.data, to: self.fileToSave, in: .cache) {
            if let error = $0 {
                XCTAssert(false, error.localizedDescription)
            }
        }
        DispatchQueue.global().async {
            PersistentStore.retrieveData(file: self.fileToSave, from: .cache) {
                switch $0 {
                case .success(let data):
                    XCTAssertEqual(data, self.data)
                    expect.fulfill()
                case .failure(let error):
                    XCTAssert(false, error.localizedDescription)
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testNoOverwrite() {
        let expect = expectation(description: "\(#function)"),
        file = self.imageTunnel.fileDescription,
        data = TestResources.contentsOf(file: file.name, type: file.ext)
        PersistentStore.save(data: data, to: self.fileToSave, in: .cache, overwrite: false) {
            if let error = $0 {
                XCTAssert(false, error.localizedDescription)
            }
        }
        DispatchQueue.global().async {
            PersistentStore.retrieveData(file: self.fileToSave, from: .cache) {
                switch $0 {
                case .success(let data):
                    XCTAssertEqual(data, self.data)
                    expect.fulfill()
                case .failure(let error):
                    XCTAssert(false, error.localizedDescription)
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

// MARK: Filename Parser
extension String {
    fileprivate var fileDescription : (name: String, ext: String) {
        let description = split(separator: ".")
        if let name = description.first, let ext = description.last {
            return (String(name), String(ext))
        } else {
            fatalError("Invalid filename")
        }
    }
}

// MARK: Test Resources
final class TestResources {
    
    private init() {}
    public static func contentsOf(file: String, type: String) -> Data {
        guard let path = Bundle(for: self).path(forResource: file, ofType: type)
            else { fatalError("File missing - \"\(file).\(type)\"") }
        do {
            return try Data(contentsOf: URL(fileURLWithPath: path))
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
