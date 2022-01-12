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
        //Arrange
        var userData = [String: AnyHashable]()
        userData["userId"] = "TestUserId"
        
        CustomerGlu.getInstance.registerDevice(userdata: userData, loadcampaigns: false) { (success, loginResponse) in
            XCTAssertNotNil(loginResponse)
            XCTAssertEqual("TestUserId", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)!)
            XCTAssertEqual("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJLaHVzaGJ1IiwiZ2x1SWQiOiJmYzY2NGYxNy1iMDI5LTQwNGYtYTE1OC01ODk3Y2EwMmNjNmIiLCJjbGllbnQiOiI4NGFjZjJhYy1iMmUwLTQ5MjctODY1My1jYmEyYjgzODE2YzIiLCJkZXZpY2VJZCI6IkQ4Q0YyNkQwLTgwRDUtNDcxQy04QkJDLTZDOTQ1MTJGNzA4MiIsImRldmljZVR5cGUiOiJpb3MiLCJpYXQiOjE2NDE4ODkxNjIsImV4cCI6MTY3MzQyNTE2Mn0.5-ShKsd-QE5WDvL188xUGu2p3_Whhrf4zU9AY_nZp-o", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN)!)
            XCTAssertEqual(true, success)
        }
    }
    
//    func test_LoginApiResource_With_InValidRequest_Returns_InValidResponse() {
//
//        let promise = expectation(description: "InValidRequest_Returns_InValidRespons")
//
//        //Arrange
//        CustomerGlu.getInstance.registerDevice(userdata: [:]) { (success, loginResponse) in
//
//            XCTAssertNil(loginResponse)
//            XCTAssertEqual(false, success)
//            promise.fulfill()
//        }
//        wait(for: [promise], timeout: 5)
//    }
    
    func test_LoadAllCampaignApiResource_With_ValidRequest_Returns_ValidResponse() {
        
        ApplicationManager.loadAllCampaignsApi(type: "", value: "", loadByparams: [:]) { (success, campaignResponse) in
            XCTAssertNotNil(campaignResponse)
            XCTAssertEqual(true, success)
        }
    }
    
    func test_AddCartCampaignApiResource_With_ValidRequest_Returns_ValidResponse() {
        
        ApplicationManager.sendEventData(eventName: "", eventProperties: ["": ""]) { success, addcartResponse in
            XCTAssertNotNil(addcartResponse)
            XCTAssertEqual(true, success)
        }
    }
}
