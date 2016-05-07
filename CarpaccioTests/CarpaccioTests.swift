//
//  CarpaccioTests.swift
//  CarpaccioTests
//
//  Created by Matias Piipari on 07/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import XCTest
@testable import Carpaccio

class CarpaccioTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSonyRAWConversion() {
        let img1URL = NSBundle(forClass: self.dynamicType).URLForResource("DSC00583", withExtension: "ARW")!

        RAWConverter().decodeContentsOfURL(img1URL,
                                           thumbnailHandler:
            { thumb in
                XCTAssert(thumb.size.width > 387 && thumb.size.width < 388, "Unexpected thumbnail width: \(thumb.size.width)")
                XCTAssert(thumb.size.width > 259 && thumb.size.height < 260, "Unexpected thumbnail height: \(thumb.size.height)")
            }, imageHandler: { img in
                XCTAssert(true, "")
            }) { err in
                //XCTFail("Error: \(err)")
            }
    }
    
}
