//
//  ServerTests.swift
//  TestServer
//
//  Created by Brennan Stehling on 9/4/16.
//  Copyright © 2016 SmallSharpTools LLC. All rights reserved.
//

import XCTest

@testable import TestServer

class ServerTests: XCTestCase {

    let webServer = WebServer()
    let requestor = Requestor()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if !webServer.isStarted {
            requestor.isDebugging = true
            webServer.start()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHelloRequest() {
        let expectation = expectationWithDescription("Hello Request")

        requestor.request(.GET, baseURL: "http://localhost:8081", path: "/hello", params: nil) { (response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let response = response {
                    debugPrint("Response: \(response)")
                    XCTAssertTrue(true, "Success")
                }
                else if let error = error {
                    debugPrint("Error: \(error.localizedDescription)")
                    XCTFail("Error: \(error.localizedDescription)")
                }

                expectation.fulfill()
            }
        }

        let timeout: NSTimeInterval = 5
        self.waitForExpectationsWithTimeout(timeout) { (error) in
            // do nothing
        }
    }

    func testDataRequest() {
        let expectation = expectationWithDescription("Data Request")

        requestor.request(.GET, baseURL: "http://localhost:8081", path: "/data", params: nil) { (response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                guard let response = response,
                    let json = response as? JSONDictionary else {
                    XCTFail("Invalid response")
                        return
                }

                debugPrint("JSON: \(json)")
                let data = json["data"] as? String
                XCTAssertTrue(data == "123", "Expects 123")

                expectation.fulfill()
            }
        }

        let timeout: NSTimeInterval = 5
        self.waitForExpectationsWithTimeout(timeout) { (error) in
            // do nothing
        }
    }

}
