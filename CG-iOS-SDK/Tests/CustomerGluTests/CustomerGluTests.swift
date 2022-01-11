import XCTest
@testable import CustomerGlu

final class CustomerGluTests: XCTestCase {

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CustomerGlu.getInstance.apnToken, "")
    }
    
    func test_LoginApiResource_With_ValidRequest_Returns_ValidResponse() {
        
        MockApi.shared.registerDevice() { (success, loginResponse) in
            XCTAssertNotNil(loginResponse)
            XCTAssertEqual("Khushbu", loginResponse?.data?.user?.userId)
            XCTAssertEqual(true, success)
        }
        
//        let userData = ["userId": "1Test",
//                        "username": "myFirstTestCase"]
//
//        let promise = expectation(description: "ValidRequest_Returns_ValidResponse")
//
//        //Arrange
//        CustomerGlu.getInstance.registerDevice(userdata: userData, loadcampaigns: false) { (success, loginResponse) in
//
//            XCTAssertNotNil(loginResponse)
//            XCTAssertEqual("1Test", loginResponse?.data?.user?.userId)
//            XCTAssertEqual(true, success)
//            promise.fulfill()
//        }
//        wait(for: [promise], timeout: 5)
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
    
    func test_LoadAllCampaignApiResource_With_ValidRequest_Returns_ValidResponse() {
        
        MockApi.shared.loadAllCampaigns() { (success, campaignResponse) in
            XCTAssertNotNil(campaignResponse)
            XCTAssertEqual(true, success)
        }
    }
    
    func test_AddCartCampaignApiResource_With_ValidRequest_Returns_ValidResponse() {
        
        MockApi.shared.addCart() { (success, addcartResponse) in
            XCTAssertNotNil(addcartResponse)
            XCTAssertEqual(true, success)
        }
    }
}
