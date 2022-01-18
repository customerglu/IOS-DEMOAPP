import XCTest
@testable import CustomerGlu

final class CustomerGluTests: XCTestCase {
   
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CustomerGlu.getInstance.apnToken, "")
    }
    
    func disableGluSdk_Method() {
        CustomerGlu.getInstance.disableGluSdk(disable: true)
        XCTAssertEqual(CustomerGlu.sdk_disable, true)
    }
        
    func enableGluSdk_Method() {
        CustomerGlu.getInstance.disableGluSdk(disable: false)
        XCTAssertEqual(CustomerGlu.sdk_disable, false)
    }
    
    func test_loginApiResource_With_ValidRequest_Returns_ValidResponse() {
      
        enableGluSdk_Method()
        
        //Arrange
        var userData = [String: AnyHashable]()
        userData["userId"] = "TestUserId"
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.loginResponse.data(using: .utf8)!
        APIManager.shared.session = session
                
        CustomerGlu.getInstance.registerDevice(userdata: userData, loadcampaigns: true) { (success, loginResponse) in
            XCTAssertNotNil(loginResponse)
            XCTAssertEqual("TestUserId", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)!)
            XCTAssertEqual("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJLaHVzaGJ1IiwiZ2x1SWQiOiJmYzY2NGYxNy1iMDI5LTQwNGYtYTE1OC01ODk3Y2EwMmNjNmIiLCJjbGllbnQiOiI4NGFjZjJhYy1iMmUwLTQ5MjctODY1My1jYmEyYjgzODE2YzIiLCJkZXZpY2VJZCI6IkQ4Q0YyNkQwLTgwRDUtNDcxQy04QkJDLTZDOTQ1MTJGNzA4MiIsImRldmljZVR5cGUiOiJpb3MiLCJpYXQiOjE2NDE4ODkxNjIsImV4cCI6MTY3MzQyNTE2Mn0.5-ShKsd-QE5WDvL188xUGu2p3_Whhrf4zU9AY_nZp-o", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN)!)
            XCTAssertEqual(true, success)
        }
    }
    
    func test_loginApiResource_With_DisableSdk_Returns_NilResponse() {
        disableGluSdk_Method()
        
        //Arrange
        var userData = [String: AnyHashable]()
        userData["userId"] = "TestUserId"

        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.loginResponse.data(using: .utf8)!
        APIManager.shared.session = session

        CustomerGlu.getInstance.registerDevice(userdata: userData, loadcampaigns: true) { (success, loginResponse) in
            XCTAssertNil(loginResponse)
            XCTAssertEqual(false, success)
        }
    }
    
    func test_updateProfileResource_With_ValidRequest_Returns_ValidResponse() {
        
        enableGluSdk_Method()
        
        //Arrange
        var userData = [String: AnyHashable]()
        userData["userId"] = UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)!
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.loginResponse.data(using: .utf8)!
        APIManager.shared.session = session
                
        CustomerGlu.getInstance.updateProfile(userdata: userData) { (success, loginResponse) in
            XCTAssertNotNil(loginResponse)
            XCTAssertEqual("TestUserId", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)!)
            XCTAssertEqual("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJLaHVzaGJ1IiwiZ2x1SWQiOiJmYzY2NGYxNy1iMDI5LTQwNGYtYTE1OC01ODk3Y2EwMmNjNmIiLCJjbGllbnQiOiI4NGFjZjJhYy1iMmUwLTQ5MjctODY1My1jYmEyYjgzODE2YzIiLCJkZXZpY2VJZCI6IkQ4Q0YyNkQwLTgwRDUtNDcxQy04QkJDLTZDOTQ1MTJGNzA4MiIsImRldmljZVR5cGUiOiJpb3MiLCJpYXQiOjE2NDE4ODkxNjIsImV4cCI6MTY3MzQyNTE2Mn0.5-ShKsd-QE5WDvL188xUGu2p3_Whhrf4zU9AY_nZp-o", UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN)!)
            XCTAssertEqual(true, success)
        }
    }
    
    func test_updateProfileResource_With_DisableSdk_Returns_NilResponse() {
        disableGluSdk_Method()
                
        //Arrange
        var userData = [String: AnyHashable]()
        userData["userId"] = UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.loginResponse.data(using: .utf8)!
        APIManager.shared.session = session

        CustomerGlu.getInstance.updateProfile(userdata: userData) { (success, loginResponse) in
            XCTAssertNil(loginResponse)
            XCTAssertEqual(false, success)
        }
    }
    
    func test_openWallet_Method() {
        
        enableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.openWallet()
    }
    
    func test_openWallet_Method_With_DisableSDK() {
        
        disableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.openWallet()
    }
    
    func test_loadAllCampaigns() {
        enableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadAllCampaigns()
    }
    
    func test_loadAllCampaigns_With_DisableSDK() {
        disableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadAllCampaigns()
    }
    
    func test_addCartCampaign() {
        enableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.addcartResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.sendEventData(eventName: "completePurchase", eventProperties: ["state": "1"])
    }
    
    func test_addCartCampaign_With_DisableSDK() {
        disableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.addcartResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.sendEventData(eventName: "completePurchase", eventProperties: ["state": "1"])
    }
    
    func test_loadCampaignById() {
        enableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadCampaignById(campaign_id: "c8173e2f-7d11-40c8-843a-17d345792d30")
    }
    
    func test_loadCampaignById_With_DisableSDK() {
        disableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadCampaignById(campaign_id: "c8173e2f-7d11-40c8-843a-17d345792d30")
    }
    
    func test_loadCampaignsByType() {
        enableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadCampaignsByType(type: "slotmachine")
    }
    
    func test_loadCampaignsByType_With_DisableSDK() {
        disableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadCampaignsByType(type: "slotmachine")
    }
    
    func test_loadCampaignByStatus() {
        enableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadCampaignByStatus(status: "pristine")
    }
    
    func test_loadCampaignByStatus_With_DisableSDK() {
        disableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadCampaignByStatus(status: "pristine")
    }
    
    func test_loadCampaignByFilter() {
        enableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadCampaignByFilter(parameters: ["type": "slotmachine"])
    }
    
    func test_loadCampaignByFilter_With_DisableSDK() {
        disableGluSdk_Method()
        
        let session = URLSessionMock()
        // Create data and tell the session to always return it
        session.data = MockData.walletResponse.data(using: .utf8)!
        APIManager.shared.session = session
        
        CustomerGlu.getInstance.loadCampaignByFilter(parameters: ["type": "slotmachine"])
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
        
    func test_LoadCustomerWebViewVC() {
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.urlStr = "https://stackoverflow.com/questions/47281375/convert-json-string-to-json-object-in-swift-4"
        customerWebViewVC.openWallet = true
        customerWebViewVC.loadViewIfNeeded()
    }
    
    func test_PushNotification() {
       // CustomerGlu.getInstance.cgapplication(UIApplication, didReceiveRemoteNotification: userInfo, backgroundAlpha: 0.5, fetchCompletionHandler: completionHandler)
    }
  
//    func test_clearGluData_method() {
//        CustomerGlu.getInstance.clearGluData()
//        XCTAssertNil(UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID))
//        XCTAssertNil(UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN))
//    }
}
