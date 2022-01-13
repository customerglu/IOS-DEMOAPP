import XCTest
@testable import CustomerGlu

final class CustomerGluTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CustomerGlu.getInstance.apnToken, "")
    }
    
    func test_disableGluSdk_Method() {
        CustomerGlu.getInstance.disableGluSdk(disable: true)
        XCTAssertEqual(CustomerGlu.sdk_disable, true)
    }
    
    func test_enableGluSdk_Method() {
        CustomerGlu.getInstance.disableGluSdk(disable: false)
        XCTAssertEqual(CustomerGlu.sdk_disable, false)
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
        
    func test_isFcmApn_Method() {
        CustomerGlu.getInstance.isFcmApn(fcmApn: "fcm")
        XCTAssertEqual(CustomerGlu.fcm_apn, "fcm")
    }
    
    func test_setDefaultBannerImage_Method() {
        CustomerGlu.getInstance.setDefaultBannerImage(bannerUrl: "")
        XCTAssertEqual(CustomerGlu.defaultBannerUrl, "")
    }
    
    func test_configureLoaderColour_Method() {
        CustomerGlu.getInstance.configureLoaderColour(color: [UIColor.red])
        XCTAssertEqual(CustomerGlu.arrColor, [UIColor.red])
    }
    
    func test_closeWebviewOnDeeplinkEvent_Method() {
        CustomerGlu.getInstance.closeWebviewOnDeeplinkEvent(close: true)
        XCTAssertEqual(CustomerGlu.auto_close_webview, true)
    }
    
    func testStringValueDecodedSuccessfully() throws {
        let data = MockData.loginResponse.data(using: .utf8)!
        do {
            let response = try JSONDecoder().decode(RegistrationModel.self, from: data)
            XCTAssertEqual(response.data?.user?.userName, "TestUser")
            XCTAssertNotNil(response)
        } catch {
            print(error)
        }
    }
    
    func test_openWallet_Method() {
        CustomerGlu.getInstance.openWallet()
        guard let topController = UIViewController.topViewController() else {
            return
        }
        XCTAssertNotNil(topController.isKind(of: CustomerWebViewController.self))
    }
    
    func test_loadingStoryBoardLoadAllCampaignViewController() {
        let storyboardVC = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
        storyboardVC.loadViewIfNeeded()
        XCTAssertNotNil(storyboardVC.tblRewardList)
    }
    
    func test_loadingStoryBoardOpenWalletViewController() {
         let storyboardVC = StoryboardType.main.instantiate(vcType: OpenWalletViewController.self)
        storyboardVC.loadViewIfNeeded()
        XCTAssertNotNil(storyboardVC.viewDidLoad)
    }
    
    func test_loadingXIBBannerCell() {
        let sut = BannerCell()
        XCTAssertNotNil(sut.imgView)
    }
}
