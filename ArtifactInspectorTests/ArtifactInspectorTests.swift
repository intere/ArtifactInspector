//
//  ArtifactInspectorTests.swift
//  ArtifactInspectorTests
//
//  Created by Eric Internicola on 8/25/17.
//  Copyright © 2017 Eric Internicola. All rights reserved.
//

import XCTest
@testable import ArtifactInspector

class ArtifactInspectorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
}

// MARK: - UserDefaults

extension ArtifactInspectorTests {

    func testDumpDefaultKeys() {

        let defaults = UserDefaults.standard


        for (key, value) in defaults.dictionaryRepresentation() {
            print("Default Key: \(key)")
        }

    }

}
