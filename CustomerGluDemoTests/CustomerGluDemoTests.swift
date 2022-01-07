//
//  CustomerGluDemoTests.swift
//  CustomerGluDemoTests
//
//  Created by kapil on 07/01/22.
//

import XCTest
@testable import CustomerGlu

class CustomerGluDemoTests: XCTestCase {

    func test_LoginApiResource_With_ValidRequest_Returns_ValidResponse() {
        
        let userData = ["userId": "1Test",
                        "username": "myFirstTestCase"]
        
        let promise = expectation(description: "ValidRequest_Returns_ValidResponse")
        
        //Arrange
        CustomerGlu.getInstance.registerDevice(userdata: userData, loadcampaigns: false) { (success, loginResponse) in
            
            XCTAssertNotNil(loginResponse)
            XCTAssertEqual("1Test", loginResponse?.data?.user?.userId)
            XCTAssertEqual(true, success)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
    }
    
    func test_LoginApiResource_With_InValidRequest_Returns_InValidResponse() {
        
        let promise = expectation(description: "InValidRequest_Returns_InValidRespons")

        //Arrange
        CustomerGlu.getInstance.registerDevice(userdata: [:]) { (success, loginResponse) in
            
            XCTAssertNil(loginResponse)
            XCTAssertEqual(false, success)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
    }
}
