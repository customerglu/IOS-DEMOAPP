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
        
        loginApiResource_With_DisableSdk_Returns_NilResponse()
        updateProfileResource_With_DisableSdk_Returns_NilResponse()
    }
    
    func loginApiResource_With_DisableSdk_Returns_NilResponse() {
        //Arrange
        var userData = [String: AnyHashable]()
        userData["userId"] = "TestUserId"
        
        CustomerGlu.getInstance.registerDevice(userdata: userData, loadcampaigns: true) { (success, loginResponse) in
            XCTAssertNil(loginResponse)
            XCTAssertEqual(false, success)
        }
    }
    
    func updateProfileResource_With_DisableSdk_Returns_NilResponse() {
        //Arrange
        var userData = [String: AnyHashable]()
        userData["userId"] = UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)
                
        CustomerGlu.getInstance.updateProfile(userdata: userData) { (success, loginResponse) in
            XCTAssertNil(loginResponse)
            XCTAssertEqual(false, success)
        }
    }
    
    func test_enableGluSdk_Method() {
        CustomerGlu.getInstance.disableGluSdk(disable: false)
        XCTAssertEqual(CustomerGlu.sdk_disable, false)
        
        loginApiResource_With_ValidRequest_Returns_ValidResponse()
        updateProfileResource_With_ValidRequest_Returns_ValidResponse()
        loadAllCampaignApiResource_With_ValidRequest_Returns_ValidResponse()
        addCartCampaignApiResource_With_ValidRequest_Returns_ValidResponse()
    }
    
    func loginApiResource_With_ValidRequest_Returns_ValidResponse() {
        //Arrange
        var userData = [String: AnyHashable]()
        userData["userId"] = "TestUserId"
                
        CustomerGlu.getInstance.registerDevice(userdata: userData, loadcampaigns: true) { (success, loginResponse) in
            XCTAssertNotNil(loginResponse)
            XCTAssertEqual("TestUserId", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)!)
            XCTAssertEqual("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJLaHVzaGJ1IiwiZ2x1SWQiOiJmYzY2NGYxNy1iMDI5LTQwNGYtYTE1OC01ODk3Y2EwMmNjNmIiLCJjbGllbnQiOiI4NGFjZjJhYy1iMmUwLTQ5MjctODY1My1jYmEyYjgzODE2YzIiLCJkZXZpY2VJZCI6IkQ4Q0YyNkQwLTgwRDUtNDcxQy04QkJDLTZDOTQ1MTJGNzA4MiIsImRldmljZVR5cGUiOiJpb3MiLCJpYXQiOjE2NDE4ODkxNjIsImV4cCI6MTY3MzQyNTE2Mn0.5-ShKsd-QE5WDvL188xUGu2p3_Whhrf4zU9AY_nZp-o", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN)!)
            XCTAssertEqual(true, success)
        }
    }
    
    func updateProfileResource_With_ValidRequest_Returns_ValidResponse() {
        //Arrange
        var userData = [String: AnyHashable]()
        userData["userId"] = UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)!
                
        CustomerGlu.getInstance.updateProfile(userdata: userData) { (success, loginResponse) in
            XCTAssertNotNil(loginResponse)
            XCTAssertEqual("TestUserId", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)!)
            XCTAssertEqual("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJLaHVzaGJ1IiwiZ2x1SWQiOiJmYzY2NGYxNy1iMDI5LTQwNGYtYTE1OC01ODk3Y2EwMmNjNmIiLCJjbGllbnQiOiI4NGFjZjJhYy1iMmUwLTQ5MjctODY1My1jYmEyYjgzODE2YzIiLCJkZXZpY2VJZCI6IkQ4Q0YyNkQwLTgwRDUtNDcxQy04QkJDLTZDOTQ1MTJGNzA4MiIsImRldmljZVR5cGUiOiJpb3MiLCJpYXQiOjE2NDE4ODkxNjIsImV4cCI6MTY3MzQyNTE2Mn0.5-ShKsd-QE5WDvL188xUGu2p3_Whhrf4zU9AY_nZp-o", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN)!)
            XCTAssertEqual(true, success)
        }
    }
    
    func loadAllCampaignApiResource_With_ValidRequest_Returns_ValidResponse() {
        ApplicationManager.loadAllCampaignsApi(type: "", value: "", loadByparams: [:]) { (success, campaignResponse) in
            XCTAssertNotNil(campaignResponse)
            XCTAssertEqual(true, success)
        }
    }
    
    func addCartCampaignApiResource_With_ValidRequest_Returns_ValidResponse() {
        ApplicationManager.sendEventData(eventName: "completePurchase", eventProperties: ["state": "1"]) { success, addcartResponse in
            XCTAssertNotNil(addcartResponse)
            XCTAssertEqual(true, success)
        }
    }
      
    func test_doValidateToken() {
        if ApplicationManager.doValidateToken() == true {
            XCTAssertTrue(ApplicationManager.doValidateToken())
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
    
    func test_getReferralId() {
        let userId = CustomerGlu.getInstance.getReferralId(deepLink: URL(string: "https://modpod.page.link/campaign?userId=TestUserId")!)
        XCTAssertEqual(userId, "TestUserId")
    }
    
    func test_openWallet_Method() {
        CustomerGlu.getInstance.openWallet()
//        guard let topController = UIViewController.topViewController() else {
//            return
//        }
//        XCTAssertNotNil(topController.isKind(of: CustomerWebViewController.self))
    }
    
    func test_loadingStoryBoardLoadAllCampaignViewController() {
        let storyboardVC = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
        storyboardVC.loadViewIfNeeded()
        XCTAssertNotNil(storyboardVC.tblRewardList)
    }
            
    func test_BaseUrl() {
        let url = ApplicationManager.baseUrl
        XCTAssertEqual(url, "api.customerglu.com/")
    }
    
    func test_StreamUrl() {
        let url = ApplicationManager.streamUrl
        XCTAssertEqual(url, "stream.customerglu.com/")
    }
    
    func test_getCrashInfo() {
        let dict = OtherUtils.shared.getCrashInfo()
        XCTAssertNotNil(dict)
    }
    
    func test_convertToDictionary() {
        let dict = OtherUtils.shared.convertToDictionary(text: MockData.loginResponse)
        XCTAssertNotNil(dict)
    }
    
    func test_getObject() {
        let data = MockData.walletResponse.data(using: .utf8)!
        do {
            let response = try JSONDecoder().decode(CampaignsModel.self, from: data)
            try UserDefaults.standard.setObject(response, forKey: Constants.WalletRewardData)
            XCTAssertNotNil(response)
        } catch {
            print(error)
        }
 
        do {
            let campaignsModel = try UserDefaults.standard.getObject(forKey: Constants.WalletRewardData, castTo: CampaignsModel.self)
            XCTAssertNotNil(campaignsModel)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func test_customerGluDidCatchCrash() {
        let dict = MockData.mockDataForCrash
        ApplicationManager.callCrashReport(stackTrace: dict["callStack"]!, isException: true, methodName: "CustomerGluCrash")
    }
    
    func test_loadingStoryBoardOpenWalletViewController() {
        let storyboardVC = StoryboardType.main.instantiate(vcType: OpenWalletViewController.self)
        storyboardVC.loadViewIfNeeded()
        XCTAssertNotNil(storyboardVC.viewDidLoad)
    }
    
    func test_loadingStoryBoardWebViewViewController() {
        let storyboardVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        storyboardVC.loadViewIfNeeded()
        XCTAssertNotNil(storyboardVC.viewDidLoad)
    }
  
    func test_clearGluData_method() {
        CustomerGlu.getInstance.clearGluData()
        XCTAssertNil(UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID))
        XCTAssertNil(UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN))
    }
}
