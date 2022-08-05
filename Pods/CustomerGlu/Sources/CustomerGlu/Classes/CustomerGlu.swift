import Foundation
import SwiftUI
import UIKit

let gcmMessageIDKey = "gcm.message_id"

struct EntryPointPopUpModel: Codable {
    public var popups: [PopUpModel]?
}

struct PopUpModel: Codable {
    public var _id: String?
    public var showcount: CGShowCount?
    public var delay: Int?
    public var backgroundopacity: Double?
    public var priority: Int?
    public var popupdate: Date?
    public var type: String?
}

@objc(CustomerGlu)

public class CustomerGlu: NSObject, CustomerGluCrashDelegate {
    
    // MARK: - Global Variable
    var spinner = SpinnerView()
    var arrFloatingButton = [FloatingButtonController]()
    
    // Singleton Instance
    @objc public static var getInstance = CustomerGlu()
    public static var sdk_disable: Bool? = false
    @objc public static var fcm_apn = ""
    public static var analyticsEvent: Bool? = false
    let userDefaults = UserDefaults.standard
    @objc public var apnToken = ""
    @objc public var fcmToken = ""
    @objc public static var defaultBannerUrl = ""
    @objc public static var arrColor = [UIColor.black]
    public static var auto_close_webview: Bool? = false
    @objc public static var topSafeAreaHeight = 44
    @objc public static var bottomSafeAreaHeight = 34
    @objc public static var topSafeAreaColor = UIColor.white
    @objc public static var bottomSafeAreaColor = UIColor.white
    public static var entryPointdata: [CGData] = []
    @objc public static var isDebugingEnabled = false
    @objc public static var isEntryPointEnabled = false
    @objc public static var activeViewController = ""
    internal var activescreenname = ""
    public static var bannersHeight: [String: Any]? = nil
        
    internal var popupDict = [PopUpModel]()
    internal var entryPointPopUpModel = EntryPointPopUpModel()
    internal var popupDisplayScreens = [String]()
    private var configScreens = [String]()
    private var popuptimer : Timer?
    public static var whiteListedDomains = [Constants.default_whitelist_doamin]
    public static var doamincode = 404
    public static var textMsg = "Requested-page-is-not-valid"
    
    private override init() {
        super.init()
        
        migrateUserDefaultKey()
        
        if UserDefaults.standard.object(forKey: Constants.CUSTOMERGLU_TOKEN) != nil {
            if CustomerGlu.isEntryPointEnabled {
                getEntryPointData()
            }
        }
        
        CustomerGluCrash.add(delegate: self)
        
        if userDefaults.object(forKey: Constants.CustomerGluCrash) != nil {
            let jsonString = decryptUserDefaultKey(userdefaultKey: Constants.CustomerGluCrash)
            let jsonData = Data(jsonString.utf8)
            do {
                let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])

                // you can now cast it with the right type
                if let crashItems = decoded as? [String: Any] {
                    // use dictFromJSON
                    ApplicationManager.callCrashReport(cglog: (crashItems["callStack"] as? String)!, isException: true, methodName: "CustomerGluCrash", user_id: decryptUserDefaultKey(userdefaultKey: Constants.CUSTOMERGLU_USERID))
                }
            } catch {
                CustomerGlu.getInstance.printlog(cglog: "private override init()", isException: false, methodName: "CustomerGlu-init", posttoserver: false)
            }
        }
    }
    
    @objc public func gluSDKDebuggingMode(enabled: Bool) {
        CustomerGlu.isDebugingEnabled = enabled
    }
    
    @objc public func enableEntryPoints(enabled: Bool) {
        CustomerGlu.isEntryPointEnabled = enabled
        if CustomerGlu.isEntryPointEnabled {
            getEntryPointData()
        }
    }
    
    @objc public func customerGluDidCatchCrash(with model: CrashModel) {

        CustomerGlu.getInstance.printlog(cglog: "\(model)", isException: false, methodName: "CustomerGlu-customerGluDidCatchCrash-1", posttoserver: false)
        let dict = [
            "name": model.name!,
            "reason": model.reason!,
            "appinfo": model.appinfo!,
            "callStack": model.callStack!] as [String: Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            let jsonString2 = String(data: jsonData, encoding: .utf8)!
            encryptUserDefaultKey(str: jsonString2, userdefaultKey: Constants.CustomerGluCrash)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc public func disableGluSdk(disable: Bool) {
        CustomerGlu.sdk_disable = disable
    }
    
    @objc public func isFcmApn(fcmApn: String) {
        CustomerGlu.fcm_apn = fcmApn
    }
    
    @objc public func setDefaultBannerImage(bannerUrl: String) {
        CustomerGlu.defaultBannerUrl = bannerUrl
    }
    
    @objc public func configureLoaderColour(color: [UIColor]) {
        CustomerGlu.arrColor = color
    }
    
    func loaderShow(withcoordinate x: CGFloat, y: CGFloat) {
        DispatchQueue.main.async { [self] in
            if let controller = topMostController() {
                controller.view.isUserInteractionEnabled = false
                spinner = SpinnerView(frame: CGRect(x: x, y: y, width: 60, height: 60))
                controller.view.addSubview(spinner)
                controller.view.bringSubviewToFront(spinner)
            }
        }
    }
    
    @objc public func getReferralId(deepLink: URL) -> String {
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let referrerUserId = queryItems?.filter({(item) in item.name == APIParameterKey.userId}).first?.value
        return referrerUserId ?? ""
    }
    
    @objc public func closeWebviewOnDeeplinkEvent(close: Bool) {
        CustomerGlu.auto_close_webview = close
    }
    
    @objc public func enableAnalyticsEvent(event: Bool) {
        CustomerGlu.analyticsEvent = event
    }
    
    func loaderHide() {
        DispatchQueue.main.async { [self] in
            if let controller = topMostController() {
                controller.view.isUserInteractionEnabled = true
                spinner.removeFromSuperview()
            }
        }
    }
    
    private func topMostController() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindowInConnectedScenes, let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        if let navController = topController as? UINavigationController {
            topController = navController.viewControllers.last!
        }
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        return topController
    }
    
    private func getDeviceName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    @objc public func cgUserNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            return
        }
        let userInfo = notification.request.content.userInfo
        
        // Change this to your preferred presentation option
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            if userInfo[NotificationsKey.glu_message_type] as? String == "push" {
                if UIApplication.shared.applicationState == .active {
                    completionHandler([[.alert, .badge, .sound]])
                }
            }
        }
    }
    
    @objc public func cgapplication(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], backgroundAlpha: Double = 0.5,auto_close_webview : Bool = CustomerGlu.auto_close_webview!, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-cgapplication", posttoserver: true)
            return
        }
        if let messageID = userInfo[gcmMessageIDKey] {
            if(true == CustomerGlu.isDebugingEnabled){
                print("Message ID: \(messageID)")
            }
        }
        
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            let nudge_url = userInfo[NotificationsKey.nudge_url]
            if(true == CustomerGlu.isDebugingEnabled){
                print(nudge_url as Any)
            }
            let page_type = userInfo[NotificationsKey.page_type]
            
            if userInfo[NotificationsKey.glu_message_type] as? String == NotificationsKey.in_app {
                
                if(true == CustomerGlu.isDebugingEnabled){
                    print(page_type as Any)
                }
                if page_type as? String == Constants.BOTTOM_SHEET_NOTIFICATION {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.BOTTOM_SHEET_NOTIFICATION, backgroundAlpha: backgroundAlpha,auto_close_webview: auto_close_webview)
                } else if page_type as? String == Constants.BOTTOM_DEFAULT_NOTIFICATION {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.BOTTOM_DEFAULT_NOTIFICATION, backgroundAlpha: backgroundAlpha,auto_close_webview: auto_close_webview)
                } else if page_type as? String == Constants.MIDDLE_NOTIFICATIONS {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: backgroundAlpha,auto_close_webview: auto_close_webview)
                } else {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: backgroundAlpha,auto_close_webview: auto_close_webview)
                }
            } else {

                return
            }
        } else {
        }
    }
    
    @objc public func presentToCustomerWebViewController(nudge_url: String, page_type: String, backgroundAlpha: Double, auto_close_webview : Bool) {
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.urlStr = nudge_url
        customerWebViewVC.auto_close_webview = auto_close_webview
        customerWebViewVC.notificationHandler = true
        customerWebViewVC.alpha = backgroundAlpha
        guard let topController = UIViewController.topViewController() else {
            return
        }
        
        if page_type == Constants.BOTTOM_SHEET_NOTIFICATION {
            customerWebViewVC.isbottomsheet = true
            #if compiler(>=5.5)
            if #available(iOS 15.0, *) {
                if let sheet = customerWebViewVC.sheetPresentationController {
                    sheet.detents = [ .medium(), .large() ]
                }
            } else {
                customerWebViewVC.modalPresentationStyle = .pageSheet
            }
            #else
            customerWebViewVC.modalPresentationStyle = .pageSheet
            #endif
        } else if page_type == Constants.BOTTOM_DEFAULT_NOTIFICATION {
            customerWebViewVC.isbottomdefault = true
            customerWebViewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customerWebViewVC.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        } else if page_type == Constants.MIDDLE_NOTIFICATIONS {
            customerWebViewVC.ismiddle = true
            customerWebViewVC.modalPresentationStyle = .overCurrentContext
        } else {
            customerWebViewVC.modalPresentationStyle = .fullScreen
        }
        topController.present(customerWebViewVC, animated: true, completion: {
            self.hideFloatingButtons()
        })
    }
    
    @objc public func displayBackgroundNotification(remoteMessage: [String: AnyHashable],auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        if CustomerGlu.sdk_disable! == true {
            CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-displayBackgroundNotification", posttoserver: false)
            return
        }
        let nudge_url = remoteMessage[NotificationsKey.nudge_url]
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.auto_close_webview = auto_close_webview
        customerWebViewVC.urlStr = nudge_url as? String ?? ""
        customerWebViewVC.notificationHandler = true
        customerWebViewVC.modalPresentationStyle = .fullScreen
        guard let topController = UIViewController.topViewController() else {
            return
        }
        topController.present(customerWebViewVC, animated: false, completion: {
            self.hideFloatingButtons()
        })
    }
    
    @objc public func notificationFromCustomerGlu(remoteMessage: [String: AnyHashable]) -> Bool {
        let strType = remoteMessage[NotificationsKey.type] as? String
        if strType == NotificationsKey.CustomerGlu {
            return true
        } else {
            return false
        }
    }
    
    @objc public func clearGluData() {
        dismissFloatingButtons(is_remove: true)
        self.arrFloatingButton.removeAll()
        popupDict.removeAll()
        CustomerGlu.entryPointdata.removeAll()
        entryPointPopUpModel = EntryPointPopUpModel()
        self.popupDisplayScreens.removeAll()
        
        userDefaults.removeObject(forKey: Constants.CUSTOMERGLU_TOKEN)
        userDefaults.removeObject(forKey: Constants.CUSTOMERGLU_USERID)
        userDefaults.removeObject(forKey: Constants.CustomerGluCrash)
        userDefaults.removeObject(forKey: Constants.CustomerGluPopupDict)
        ApplicationManager.appSessionId = UUID().uuidString
    }
        
    // MARK: - API Calls Methods
    @objc public func registerDevice(userdata: [String: AnyHashable], loadcampaigns: Bool = false, completion: @escaping (Bool) -> Void) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userdata["userId"] == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call registerDevice", isException: false, methodName: "CustomerGlu-registerDevice-1", posttoserver: true)
            CustomerGlu.bannersHeight = [String:Any]()
            completion(false)
            return
        }
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            if(true == CustomerGlu.isDebugingEnabled){
                print(uuid)
            }
            userData[APIParameterKey.deviceId] = uuid
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let writekey = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String
        userData[APIParameterKey.deviceType] = "ios"
        userData[APIParameterKey.deviceName] = getDeviceName()
        userData[APIParameterKey.appVersion] = appVersion
        userData[APIParameterKey.writeKey] = writekey
        
        if CustomerGlu.fcm_apn == "fcm" {
            userData[APIParameterKey.apnsDeviceToken] = ""
            userData[APIParameterKey.firebaseToken] = fcmToken
        } else {
            userData[APIParameterKey.firebaseToken] = ""
            userData[APIParameterKey.apnsDeviceToken] = apnToken
        }
        
        APIManager.userRegister(queryParameters: userData as NSDictionary) { result in
            switch result {
                case .success(let response):
                    if response.success! {
                        self.encryptUserDefaultKey(str: response.data?.token ?? "", userdefaultKey: Constants.CUSTOMERGLU_TOKEN)
                        self.encryptUserDefaultKey(str: response.data?.user?.userId ?? "", userdefaultKey: Constants.CUSTOMERGLU_USERID)
                        self.userDefaults.synchronize()
                        if CustomerGlu.isEntryPointEnabled {
                            CustomerGlu.bannersHeight = nil
                            APIManager.getEntryPointdata(queryParameters: [:]) { result in
                                switch result {
                                    case .success(let responseGetEntry):
                                        DispatchQueue.main.async {
                                            self.dismissFloatingButtons(is_remove: false)
                                        }
                                        CustomerGlu.entryPointdata.removeAll()
                                        CustomerGlu.entryPointdata = responseGetEntry.data
                                        
                                        // FLOATING Buttons
                                        let floatingButtons = CustomerGlu.entryPointdata.filter {
                                            $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP"
                                        }
                                                            
                                        self.entryPointInfoAddDelete(entryPoint: floatingButtons)
                                        self.addFloatingBtns()
                                        self.postBannersCount()
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object: nil, userInfo: nil)
                                        completion(true)
                                        
                                    case .failure(let error):
                                        CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-registerDevice-2", posttoserver: true)
                                        CustomerGlu.bannersHeight = [String:Any]()
                                        completion(true)
                                }
                            }
                        } else {
                            CustomerGlu.bannersHeight = [String:Any]()
                            completion(true)
                        }
                        
                        if loadcampaigns == true {
                            ApplicationManager.openWalletApi { success, _ in
                                if success {
                                } else {
                                }
                            }
                        }
                    } else {
                        CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-registerDevice-3", posttoserver: true)
                        CustomerGlu.bannersHeight = [String:Any]()
                        completion(false)
                    }
                case .failure(let error):
                    CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-registerDevice-4", posttoserver: true)
                    CustomerGlu.bannersHeight = [String:Any]()
                    completion(false)
            }
        }
    }
    
    @objc public func updateProfile(userdata: [String: AnyHashable], completion: @escaping (Bool) -> Void) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call updateProfile", isException: false, methodName: "CustomerGlu-updateProfile-1", posttoserver: true)
            CustomerGlu.bannersHeight = [String:Any]()
            completion(false)
            return
        }
        
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            if(true == CustomerGlu.isDebugingEnabled){
                print(uuid)
            }
            userData[APIParameterKey.deviceId] = uuid
        }
        let user_id = decryptUserDefaultKey(userdefaultKey: Constants.CUSTOMERGLU_USERID)
        if user_id.count < 0 {
            CustomerGlu.getInstance.printlog(cglog: "user_id is nil", isException: false, methodName: "CustomerGlu-updateProfile-2", posttoserver: true)
            return
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let writekey = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String
        userData[APIParameterKey.deviceType] = "ios"
        userData[APIParameterKey.deviceName] = getDeviceName()
        userData[APIParameterKey.appVersion] = appVersion
        userData[APIParameterKey.writeKey] = writekey
        userData[APIParameterKey.userId] = user_id
        
        if CustomerGlu.fcm_apn == "fcm" {
            userData[APIParameterKey.apnsDeviceToken] = ""
            userData[APIParameterKey.firebaseToken] = fcmToken
        } else {
            userData[APIParameterKey.firebaseToken] = ""
            userData[APIParameterKey.apnsDeviceToken] = apnToken
        }
        
        APIManager.userRegister(queryParameters: userData as NSDictionary) { result in
            switch result {
                case .success(let response):
                    if response.success! {
                        self.encryptUserDefaultKey(str: response.data?.token ?? "", userdefaultKey: Constants.CUSTOMERGLU_TOKEN)
                        self.encryptUserDefaultKey(str: response.data?.user?.userId ?? "", userdefaultKey: Constants.CUSTOMERGLU_USERID)
                        self.userDefaults.synchronize()
                        
                        if CustomerGlu.isEntryPointEnabled {
                            CustomerGlu.bannersHeight = nil
                            APIManager.getEntryPointdata(queryParameters: [:]) { result in
                                switch result {
                                    case .success(let responseGetEntry):
                                        DispatchQueue.main.async {
                                            self.dismissFloatingButtons(is_remove: false)
                                        }
                                        CustomerGlu.entryPointdata.removeAll()
                                        CustomerGlu.entryPointdata = responseGetEntry.data

                                        // FLOATING Buttons
                                        let floatingButtons = CustomerGlu.entryPointdata.filter {
                                            $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP"
                                        }
                                                            
                                        self.entryPointInfoAddDelete(entryPoint: floatingButtons)
                                        self.addFloatingBtns()
                                        self.postBannersCount()
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object: nil, userInfo: nil)
                                        completion(true)
                                        
                                    case .failure(let error):
                                        CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-updateProfile-3", posttoserver: true)
                                        CustomerGlu.bannersHeight = [String:Any]()
                                        completion(true)
                                }
                            }
                        } else {
                            CustomerGlu.bannersHeight = [String:Any]()
                            completion(true)
                        }
                    } else {
                        CustomerGlu.getInstance.printlog(cglog: "", isException: false, methodName: "CustomerGlu-updateProfile-4", posttoserver: true)
                        CustomerGlu.bannersHeight = [String:Any]()
                        completion(false)
                    }
                case .failure(let error):
                    CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-updateProfile-5", posttoserver: true)
                    CustomerGlu.bannersHeight = [String:Any]()
                    completion(false)
            }
        }
    }
    
    private func getEntryPointData() {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call getEntryPointData", isException: false, methodName: "CustomerGlu-getEntryPointData", posttoserver: true)
            CustomerGlu.bannersHeight = [String:Any]()
            return
        }
        CustomerGlu.bannersHeight = nil
        APIManager.getEntryPointdata(queryParameters: [:]) { [self] result in
            switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        dismissFloatingButtons(is_remove: false)
                    }
                    CustomerGlu.entryPointdata.removeAll()
                    CustomerGlu.entryPointdata = response.data

                    // FLOATING Buttons
                    let floatingButtons = CustomerGlu.entryPointdata.filter {
                        $0.mobile.container.type == "FLOATING" || $0.mobile.container.type == "POPUP"
                    }
                                        
                    entryPointInfoAddDelete(entryPoint: floatingButtons)
                    addFloatingBtns()
                    postBannersCount()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("EntryPointLoaded").rawValue), object: nil, userInfo: nil)
                case .failure(let error):
                    CustomerGlu.bannersHeight = [String:Any]()
                    CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-getEntryPointData", posttoserver: true)
            }
        }
    }
    
    private func entryPointInfoAddDelete(entryPoint: [CGData]) {
                
        if entryPoint.count > 0 {
            
            let jsonString = decryptUserDefaultKey(userdefaultKey: Constants.CustomerGluPopupDict)
            let jsonData = Data(jsonString.utf8)
            let decoder = JSONDecoder()
            do {
                if(jsonData.count > 0){
                    let popupItems = try decoder.decode(EntryPointPopUpModel.self, from: jsonData)
                    popupDict = popupItems.popups!
                }
            } catch {
                print(error.localizedDescription)
            }
            
            for dict in entryPoint {
                if popupDict.contains(where: { $0._id == dict._id }) {
                    
                    if let index = popupDict.firstIndex(where: {$0._id == dict._id}) {
                        
                        var refreshlocal : Bool = false
                        if(dict.mobile.conditions.showCount.dailyRefresh == true && popupDict[index].showcount?.dailyRefresh == true){
                            
                            if !(Calendar.current.isDate(popupDict[index].popupdate!, equalTo: Date(), toGranularity: .day)){
                                refreshlocal = true
                            }
                            
                        }else if(dict.mobile.conditions.showCount.dailyRefresh != popupDict[index].showcount?.dailyRefresh){
                            refreshlocal = true
                        }
                        
                        if (true == refreshlocal){
                            popupDict[index]._id = dict._id
                            popupDict[index].showcount = dict.mobile.conditions.showCount
                            popupDict[index].showcount?.count = 0
                            popupDict[index].delay = dict.mobile.conditions.delay
                            popupDict[index].backgroundopacity = dict.mobile.conditions.backgroundOpacity
                            popupDict[index].priority = dict.mobile.conditions.priority
                            popupDict[index].popupdate = Date()
                            popupDict[index].type = dict.mobile.container.type
                        }
                    }
                    
                } else {
                    var popupInfo = PopUpModel()
                    popupInfo._id = dict._id
                    popupInfo.showcount = dict.mobile.conditions.showCount
                    popupInfo.showcount?.count = 0
                    popupInfo.delay = dict.mobile.conditions.delay
                    popupInfo.backgroundopacity = dict.mobile.conditions.backgroundOpacity
                    popupInfo.priority = dict.mobile.conditions.priority
                    popupInfo.popupdate = Date()
                    popupInfo.type = dict.mobile.container.type
                    popupDict.append(popupInfo)
                }
            }
            
            for item in popupDict {
                if entryPoint.contains(where: { $0._id == item._id }) {

                } else {
                    // remove item from popupDict
                    if let index = popupDict.firstIndex(where: {$0._id == item._id}) {
                        popupDict.remove(at: index)
                    }
                }
            }
            
            entryPointPopUpModel.popups = popupDict
            
            let data = try! JSONEncoder().encode(entryPointPopUpModel)
            let jsonString2 = String(data: data, encoding: .utf8)!
            encryptUserDefaultKey(str: jsonString2, userdefaultKey: Constants.CustomerGluPopupDict)
        }
    }
    
    @objc public func openWalletWithURL(url: String, auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: url, page_type: Constants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: 0.5,auto_close_webview: auto_close_webview)
    }
    
    @objc public func openWallet(auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call openWallet", isException: false, methodName: "CustomerGlu-openWallet", posttoserver: true)
            return
        }
        
        DispatchQueue.main.async {
            let openWalletVC = StoryboardType.main.instantiate(vcType: OpenWalletViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            openWalletVC.auto_close_webview = auto_close_webview
            openWalletVC.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(openWalletVC, animated: true, completion: nil)
        }
    }
    
    @objc public func loadAllCampaigns(auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call loadAllCampaigns", isException: false, methodName: "CustomerGlu-loadAllCampaigns", posttoserver: true)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            loadAllCampign.auto_close_webview = auto_close_webview
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func loadCampaignById(campaign_id: String, auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call loadCampaignById", isException: false, methodName: "CustomerGlu-loadCampaignById", posttoserver: true)
            return
        }
        
        DispatchQueue.main.async {
            let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            customerWebViewVC.auto_close_webview = auto_close_webview
            customerWebViewVC.modalPresentationStyle = .fullScreen
            customerWebViewVC.iscampignId = true
            customerWebViewVC.campaign_id = campaign_id
            self.hideFloatingButtons()
            topController.present(customerWebViewVC, animated: false, completion: nil)
        }
    }
    
    @objc public func loadCampaignsByType(type: String, auto_close_webview : Bool = CustomerGlu.auto_close_webview! ) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call loadCampaignsByType", isException: false, methodName: "CustomerGlu-loadCampaignsByType", posttoserver: true)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.auto_close_webview = auto_close_webview
            loadAllCampign.loadCampignType = APIParameterKey.type
            loadAllCampign.loadCampignValue = type
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func loadCampaignByStatus(status: String, auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call loadCampaignByStatus", isException: false, methodName: "CustomerGlu-loadCampaignByStatus", posttoserver: true)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.auto_close_webview = auto_close_webview
            loadAllCampign.loadCampignType = APIParameterKey.status
            loadAllCampign.loadCampignValue = status
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func loadCampaignByFilter(parameters: NSDictionary, auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
            CustomerGlu.getInstance.printlog(cglog: "Fail to call loadCampaignByFilter", isException: false, methodName: "CustomerGlu-loadCampaignByFilter", posttoserver: true)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.loadByparams = parameters
            loadAllCampign.auto_close_webview = auto_close_webview
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            self.hideFloatingButtons()
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc public func sendEventData(eventName: String, eventProperties: [String: Any]?) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true || userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID) == nil {
                CustomerGlu.getInstance.printlog(cglog: "Fail to call sendEventData", isException: false, methodName: "CustomerGlu-sendEventData-1", posttoserver: true)
            return
        }
        
        ApplicationManager.sendEventData(eventName: eventName, eventProperties: eventProperties) { success, addCartModel in
            if success {
                if(true == CustomerGlu.isDebugingEnabled){
                    print(addCartModel as Any)
                }
            } else {
                CustomerGlu.getInstance.printlog(cglog: "Fail to call sendEventData", isException: false, methodName: "CustomerGlu-sendEventData-2", posttoserver: true)
            }
        }
    }
    
    @objc public func configureSafeArea(topHeight: Int, bottomHeight: Int, topSafeAreaColor: UIColor, bottomSafeAreaColor: UIColor) {
        CustomerGlu.topSafeAreaHeight = topHeight
        CustomerGlu.bottomSafeAreaHeight = bottomHeight
        CustomerGlu.topSafeAreaColor = topSafeAreaColor
        CustomerGlu.bottomSafeAreaColor = bottomSafeAreaColor
    }
    
    private func addFloatingButton(btnInfo: CGData) {
        DispatchQueue.main.async {
            self.arrFloatingButton.append(FloatingButtonController(btnInfo: btnInfo))
        }
    }
    
    internal func hideFloatingButtons() {
        for floatBtn in self.arrFloatingButton {
            floatBtn.hideFloatingButton(ishidden: true)
        }
    }
    
    internal func dismissFloatingButtons(is_remove: Bool) {
        for floatBtn in self.arrFloatingButton {
            floatBtn.dismissFloatingButton(is_remove: is_remove)
        }
    }
    
    internal func showFloatingButtons() {
        CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
    }

    internal func validateURL(url: URL) -> URL {
        // return url;
        let host = url.host
        if(host != nil && host!.count > 0){
            for str_url in CustomerGlu.whiteListedDomains {
                if (host!.hasSuffix(str_url)){
                    return url
                }
            }
        }

        return URL(string: ("\(Constants.default_redirect_url)code=\(String(CustomerGlu.doamincode))&message=\(CustomerGlu.textMsg)"))!
    }
    
    public func configureWhiteListedDomains(domains: [String]){
        CustomerGlu.whiteListedDomains = domains
        CustomerGlu.whiteListedDomains.append(Constants.default_whitelist_doamin)
    }
    
    public func configureDomainCodeMsg(code: Int, message: String){
        CustomerGlu.doamincode = code
        CustomerGlu.textMsg = message
    }

    public func setCurrentClassName(className: String) {
        
        if(popuptimer != nil){
            popuptimer?.invalidate()
            popuptimer = nil
        }
        
        if CustomerGlu.isEntryPointEnabled {
            if CustomerGlu.isDebugingEnabled {
                // API Call Collect ViewController Name & Post
                
                if !configScreens.contains(className) {
                    configScreens.append(className)
                    
                    var eventInfo = [String: AnyHashable]()
                    eventInfo[APIParameterKey.activityIdList] = configScreens
                    
                    APIManager.entrypoints_config(queryParameters: eventInfo as NSDictionary) { result in
                        switch result {
                        case .success(let response):
                            if(true == CustomerGlu.isDebugingEnabled){
                                print(response)
                            }
                        case .failure(let error):
                            CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CustomerGlu-setCurrentClassName", posttoserver: true)
                        }
                    }
                }
            }
            
            CustomerGlu.getInstance.activescreenname = className

            for floatBtn in self.arrFloatingButton {
                floatBtn.hideFloatingButton(ishidden: true)
                if (floatBtn.floatInfo?.mobile.container.ios.allowedActitivityList.count)! > 0 && (floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.count)! > 0 {
                    if  !(floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.contains(className))! {
                        floatBtn.hideFloatingButton(ishidden: false)
                        callEventPublishNudge(data: floatBtn.floatInfo!, className: className, actionType: "LOADED")
                    }
                } else if (floatBtn.floatInfo?.mobile.container.ios.allowedActitivityList.count)! > 0 {
                    if (floatBtn.floatInfo?.mobile.container.ios.allowedActitivityList.contains(className))! {
                        floatBtn.hideFloatingButton(ishidden: false)
                        callEventPublishNudge(data: floatBtn.floatInfo!, className: className, actionType: "LOADED")
                    }
                } else if (floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.count)! > 0 {
                    if !(floatBtn.floatInfo?.mobile.container.ios.disallowedActitivityList.contains(className))! {
                        floatBtn.hideFloatingButton(ishidden: false)
                        callEventPublishNudge(data: floatBtn.floatInfo!, className: className, actionType: "LOADED")
                    }
                }
            }
            
            showPopup(className: className)
        }
    }
    
    private func addFloatingBtns() {
        // FLOATING Buttons
        let floatingButtons = popupDict.filter {
            $0.type == "FLOATING"
        }
        
        if floatingButtons.count != 0 {
            for floatBtn in floatingButtons {
                let floatButton = CustomerGlu.entryPointdata.filter {
                    $0._id == floatBtn._id
                }
                
                if ((floatButton[0].mobile.content.count > 0) && (floatBtn.showcount?.count)! < floatButton[0].mobile.conditions.showCount.count) {
                    self.addFloatingButton(btnInfo: floatButton[0])
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
            })

        }
    }
    
    internal func postBannersCount() {

        var postInfo: [String: Any] = [:]
        
        let banners = CustomerGlu.entryPointdata.filter {
            $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0
        }
        
        if(banners.count > 0){
            for banner in banners {
                postInfo[banner.mobile.container.bannerId] = banner.mobile.content.count
            }
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_BANNER_LOADED").rawValue), object: nil, userInfo: postInfo)
        
        let bannersforheight = CustomerGlu.entryPointdata.filter {
            $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId != nil && $0.mobile.container.bannerId.count > 0 && (Int($0.mobile.container.height)!) > 0 && $0.mobile.content.count > 0
        }
        if bannersforheight.count > 0 {
            CustomerGlu.bannersHeight = [String:Any]()
            for banner in bannersforheight {
                CustomerGlu.bannersHeight![banner.mobile.container.bannerId] = Int(banner.mobile.container.height)
            }
        }
        if (CustomerGlu.bannersHeight == nil) {
            CustomerGlu.bannersHeight = [String:Any]()
        }
    }
    
    private func showPopup(className: String) {
     
        //POPUPS
        let popups = popupDict.filter {
            $0.type == "POPUP"
        }
        
        let sortedPopup = popups.sorted{$0.priority! > $1.priority!}
        
        if sortedPopup.count > 0 {
            for popupShow in sortedPopup {
                
                let finalPopUp = CustomerGlu.entryPointdata.filter {
                    $0._id == popupShow._id
                }
                
                if (finalPopUp.count > 0 && ((finalPopUp[0].mobile.content.count > 0) && (popupShow.showcount?.count)! < finalPopUp[0].mobile.conditions.showCount.count)) {
                    
                        var userInfo = [String: Any]()
                        userInfo["finalPopUp"] = (finalPopUp[0] )
                        userInfo["popupShow"] = (popupShow )
                        
                        if finalPopUp[0].mobile.container.ios.allowedActitivityList.count > 0 && finalPopUp[0].mobile.container.ios.disallowedActitivityList.count > 0 {
                            if !finalPopUp[0].mobile.container.ios.disallowedActitivityList.contains(className) {
                                if !popupDisplayScreens.contains(className) {
                                    popuptimer = Timer.scheduledTimer(timeInterval: TimeInterval(finalPopUp[0].mobile.conditions.delay), target: self, selector: #selector(showPopupAfterTime(sender:)), userInfo: userInfo, repeats: false)
                                    return
                                }
                            }
                        }  else if finalPopUp[0].mobile.container.ios.allowedActitivityList.count > 0 {
                            if finalPopUp[0].mobile.container.ios.allowedActitivityList.contains(className) {
                                
                                if !popupDisplayScreens.contains(className) {
                                    popuptimer = Timer.scheduledTimer(timeInterval: TimeInterval(finalPopUp[0].mobile.conditions.delay), target: self, selector: #selector(showPopupAfterTime(sender:)), userInfo: userInfo, repeats: false)
                                    return
                                }
                            }
                        } else if finalPopUp[0].mobile.container.ios.disallowedActitivityList.count > 0 {
                            
                            if !finalPopUp[0].mobile.container.ios.disallowedActitivityList.contains(className) {
                                
                                if !popupDisplayScreens.contains(className) {
                                    popuptimer = Timer.scheduledTimer(timeInterval: TimeInterval(finalPopUp[0].mobile.conditions.delay), target: self, selector: #selector(showPopupAfterTime(sender:)), userInfo: userInfo, repeats: false)
                                    
                                    return
                                }
                            }
                        }
                }
            }
        }
    }
    
    internal func updateShowCount(showCount: PopUpModel, eventData: CGData) {
        var showCountNew = showCount
        showCountNew.showcount?.count += 1
        
        if let index = popupDict.firstIndex(where: {$0._id == showCountNew._id}) {
            popupDict.remove(at: index)
            popupDict.insert(showCountNew, at: index)
        }
        
        entryPointPopUpModel.popups = popupDict
        
        let data = try! JSONEncoder().encode(entryPointPopUpModel)
        let jsonString2 = String(data: data, encoding: .utf8)!
        encryptUserDefaultKey(str: jsonString2, userdefaultKey: Constants.CustomerGluPopupDict)
    }
    
    @objc private  func showPopupAfterTime(sender: Timer) {
        
        if popuptimer != nil && !popupDisplayScreens.contains(CustomerGlu.getInstance.activescreenname) {
            
            let userInfo = sender.userInfo as! [String:Any]
            let finalPopUp = userInfo["finalPopUp"] as! CGData
            let showCount = userInfo["popupShow"] as! PopUpModel
            
            popuptimer?.invalidate()
            popuptimer = nil
            
            if finalPopUp.mobile.content[0].openLayout == "FULL-DEFAULT" {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId)!, page_type: Constants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5)
            } else if finalPopUp.mobile.content[0].openLayout == "BOTTOM-DEFAULT" {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId)!, page_type: Constants.BOTTOM_DEFAULT_NOTIFICATION, backgroundAlpha: finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5)
            }  else if finalPopUp.mobile.content[0].openLayout == "BOTTOM-SLIDER" {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId)!, page_type: Constants.BOTTOM_SHEET_NOTIFICATION, backgroundAlpha: finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5)
            } else {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (finalPopUp.mobile.content[0].campaignId)!, page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: finalPopUp.mobile.conditions.backgroundOpacity ?? 0.5)
            }
            
            
            self.popupDisplayScreens.append(CustomerGlu.getInstance.activescreenname)
            updateShowCount(showCount: showCount, eventData: finalPopUp)
            callEventPublishNudge(data: finalPopUp, className: CustomerGlu.getInstance.activescreenname, actionType: "OPEN")
            
        }
    }
    
    internal func callEventPublishNudge(data: CGData, className: String, actionType: String) {
        var actionTarget = ""
        if data.mobile.content[0].campaignId.count == 0 {
            actionTarget = "WALLET"
        } else if data.mobile.content[0].campaignId.contains("http://") || data.mobile.content[0].campaignId.contains("https://") {
            actionTarget = "CUSTOM_URL"
        } else {
            actionTarget = "CAMPAIGN"
        }
        
        eventPublishNudge(pageName: className, nudgeId: data.mobile.content[0]._id, actionType: actionType, actionTarget: actionTarget, pageType: data.mobile.content[0].openLayout, campaignId: data.mobile.content[0].campaignId,nudgeType: data.mobile.container.type)
    }
  
    internal func openCampaignById(campaign_id: String, page_type: String, backgroundAlpha: Double, auto_close_webview : Bool = CustomerGlu.auto_close_webview!) {
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.iscampignId = true
        customerWebViewVC.alpha = backgroundAlpha
        customerWebViewVC.campaign_id = campaign_id
        customerWebViewVC.auto_close_webview = auto_close_webview
        guard let topController = UIViewController.topViewController() else {
            return
        }
        
        if page_type == Constants.BOTTOM_SHEET_NOTIFICATION {
            customerWebViewVC.isbottomsheet = true
            #if compiler(>=5.5)
            if #available(iOS 15.0, *) {
                if let sheet = customerWebViewVC.sheetPresentationController {
                    sheet.detents = [ .medium(), .large() ]
                }
            } else {
                customerWebViewVC.modalPresentationStyle = .pageSheet
            }
            #else
            customerWebViewVC.modalPresentationStyle = .pageSheet
            #endif
        } else if page_type == Constants.BOTTOM_DEFAULT_NOTIFICATION {
            customerWebViewVC.isbottomdefault = true
            customerWebViewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customerWebViewVC.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        } else if page_type == Constants.MIDDLE_NOTIFICATIONS {
            customerWebViewVC.ismiddle = true
            customerWebViewVC.modalPresentationStyle = .overCurrentContext
        } else {
            customerWebViewVC.modalPresentationStyle = .fullScreen
        }
        topController.present(customerWebViewVC, animated: true) {
            CustomerGlu.getInstance.hideFloatingButtons()
        }
    }
    
    private func eventPublishNudge(pageName: String, nudgeId: String, actionType: String, actionTarget: String, pageType: String, campaignId: String, nudgeType:String ) {
        var eventInfo = [String: AnyHashable]()
        eventInfo[APIParameterKey.nudgeType] = nudgeType

        eventInfo[APIParameterKey.pageName] = pageName
        eventInfo[APIParameterKey.nudgeId] = nudgeId
        eventInfo[APIParameterKey.actionTarget] = actionTarget
        eventInfo[APIParameterKey.actionType] = actionType
        eventInfo[APIParameterKey.pageType] = pageType

        
        
        eventInfo[APIParameterKey.campaignId] = "CAMPAIGNID_NOTPRESENT"
        if actionTarget == "CAMPAIGN" {
            if campaignId.count > 0 {
                if !(campaignId.contains("http://") || campaignId.contains("https://")) {
                    eventInfo[APIParameterKey.campaignId] = campaignId
                }
            }
        }

        eventInfo[APIParameterKey.optionalPayload] = [String: String]() as [String: String]

        ApplicationManager.publishNudge(eventNudge: eventInfo) { success, _ in
            if success {

            } else {
                CustomerGlu.getInstance.printlog(cglog: "Fail to call publishNudge", isException: false, methodName: "CustomerGlu-eventPublishNudge", posttoserver: true)
            }
        }
    }
    
//    (stackTrace: String = "", isException: Bool = false, methodName: String = "")
    internal func printlog(cglog: String = "", isException: Bool = false, methodName: String = "",posttoserver:Bool = false) {
        if(true == CustomerGlu.isDebugingEnabled){
            print("CG-LOGS: "+methodName+" : "+cglog)
        }
        
        if(true == posttoserver){
            ApplicationManager.callCrashReport(cglog: cglog, isException: isException, methodName: methodName, user_id:  decryptUserDefaultKey(userdefaultKey: Constants.CUSTOMERGLU_USERID))
        }
    }
    
    private func migrateUserDefaultKey() {
        if userDefaults.object(forKey: Constants.CUSTOMERGLU_TOKEN_OLD) != nil {
            encryptUserDefaultKey(str: UserDefaults.standard.object(forKey: Constants.CUSTOMERGLU_TOKEN_OLD) as! String, userdefaultKey: Constants.CUSTOMERGLU_TOKEN)
            userDefaults.removeObject(forKey: Constants.CUSTOMERGLU_TOKEN_OLD)
        }
        
        if userDefaults.object(forKey: Constants.CUSTOMERGLU_USERID_OLD) != nil {
            encryptUserDefaultKey(str: UserDefaults.standard.object(forKey: Constants.CUSTOMERGLU_USERID_OLD) as! String, userdefaultKey: Constants.CUSTOMERGLU_USERID)
            userDefaults.removeObject(forKey: Constants.CUSTOMERGLU_USERID_OLD)
        }
        
        if userDefaults.object(forKey: Constants.CustomerGluCrash_OLD) != nil {
            do {
                // retrieving a value for a key
                if let data = userDefaults.data(forKey: Constants.CustomerGluCrash_OLD),
                   let crashItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Dictionary<String, Any> {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: crashItems, options: .prettyPrinted)
                        // here "jsonData" is the dictionary encoded in JSON data
                        let jsonString2 = String(data: jsonData, encoding: .utf8)!
                        encryptUserDefaultKey(str: jsonString2, userdefaultKey: Constants.CustomerGluCrash)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } catch {
                print(error)
            }
            userDefaults.removeObject(forKey: Constants.CustomerGluCrash_OLD)
        }
        
        if userDefaults.object(forKey: Constants.CustomerGluPopupDict_OLD) != nil {
            do {
                let popupItems = try userDefaults.getObject(forKey: Constants.CustomerGluPopupDict_OLD, castTo: EntryPointPopUpModel.self)
                popupDict = popupItems.popups!
            } catch {
                print(error.localizedDescription)
            }
            entryPointPopUpModel.popups = popupDict

            let data = try! JSONEncoder().encode(entryPointPopUpModel)
            let jsonString2 = String(data: data, encoding: .utf8)!
            encryptUserDefaultKey(str: jsonString2, userdefaultKey: Constants.CustomerGluPopupDict)
            userDefaults.removeObject(forKey: Constants.CustomerGluPopupDict_OLD)
        }
    }
    
    
    private func encryptUserDefaultKey(str: String, userdefaultKey: String) {
        self.userDefaults.set(EncryptDecrypt.shared.encryptText(str: str), forKey: userdefaultKey)
    }
    
    internal func decryptUserDefaultKey(userdefaultKey: String) -> String {
        if UserDefaults.standard.object(forKey: userdefaultKey) != nil {
            return EncryptDecrypt.shared.decryptText(str: UserDefaults.standard.string(forKey: userdefaultKey)!)
        }
        return ""
    }
}
