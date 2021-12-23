import Foundation
import SwiftUI
import UIKit

let gcmMessageIDKey = "gcm.message_id"

public class CustomerGlu: NSObject, CustomerGluCrashDelegate {
    
    // MARK: - Global Variable
    var spinner = SpinnerView()
   
    // Singleton Instance
    public static var getInstance = CustomerGlu()
    public static var sdk_disable: Bool? = false
    public static var fcm_apn = "fcm"
    let userDefaults = UserDefaults.standard
    public var apnToken = ""
    public var fcmToken = ""
    public static var defaultBannerUrl = URL(string: "")
    
    private override init() {
        super.init()
        CustomerGluCrash.add(delegate: self)
        do {
            // retrieving a value for a key
            if let data = userDefaults.data(forKey: Constants.CustomerGluCrash),
               let crashItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Dictionary<String, Any> {
                let user_id = userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID)
                if user_id == nil && user_id?.count ?? 0 < 0 {
                    return
                }
                var params = convertToDictionary(text: (crashItems["appinfo"] as? String)!)
                params!["stack_trace"] = crashItems["callStack"]
                params!["user_id"] = user_id
                params!["version"] = "1.0.0"
                params!["method"] = ""
                crashReport(parameters: (params as NSDictionary?)!) { success, _ in
                    if success {
                        self.userDefaults.removeObject(forKey: Constants.CustomerGluCrash)
                        self.userDefaults.synchronize()
                    } else {
                        print("error")
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public func customerGluDidCatchCrash(with model: CrashModel) {
        print("\(model)")
        let dict = [
            "name": model.name!,
            "reason": model.reason!,
            "appinfo": model.appinfo!,
            "callStack": model.callStack!] as [String: Any]
        do {
            // setting a value for a key
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: true)
            userDefaults.set(encodedData, forKey: Constants.CustomerGluCrash)
        } catch {
            print(error)
        }
    }
    
    @Published var campaigndata = CampaignsModel()
    
    public func disableGluSdk(disable: Bool) {
        CustomerGlu.sdk_disable = disable
    }
    
    public func isFcmApn(fcmApn: String) {
        CustomerGlu.fcm_apn = fcmApn
    }
    
    public func setDefaultBannerUrl(url: URL) {
        CustomerGlu.defaultBannerUrl = url
    }
    
    func loaderShow(withcoordinate x: CGFloat, y: CGFloat) {
        DispatchQueue.main.async { [self] in
            if let controller = topMostController() {
                spinner = SpinnerView(frame: CGRect(x: x, y: y, width: 60, height: 60))
                controller.view.addSubview(spinner)
                controller.view.bringSubviewToFront(spinner)
            }
        }
    }
    
    public func getReferralId(deepLink: URL) -> String {
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let referrerUserId = queryItems?.filter({(item) in item.name == APIParameterKey.userId}).first?.value
        return referrerUserId ?? ""
    }
    
    func loaderHide() {
        DispatchQueue.main.async { [self] in
            spinner.removeFromSuperview()
        }
    }
    
    func topMostController() -> UIViewController? {
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
    
    public func cgUserNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
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
    
    public func cgapplication(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], backgroundAlpha: Double = 0.5, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            let nudge_url = userInfo[NotificationsKey.nudge_url]
            print(nudge_url as Any)
            let page_type = userInfo[NotificationsKey.page_type]
            
            if userInfo[NotificationsKey.glu_message_type] as? String == NotificationsKey.in_app {
                print(page_type as Any)
                if page_type as? String == Constants.BOTTOM_SHEET_NOTIFICATION {
                    let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
                    customerWebViewVC.urlStr = nudge_url as? String ?? ""
                    customerWebViewVC.notificationHandler = true
                    customerWebViewVC.isbottomsheet = true
                    customerWebViewVC.alpha = backgroundAlpha
                    guard let topController = UIViewController.topViewController() else {
                        return
                    }
                    if #available(iOS 15.0, *) {
                        if let sheet = customerWebViewVC.sheetPresentationController {
                            sheet.detents = [ .medium(), .large() ]
                        }
                    } else {
                        customerWebViewVC.modalPresentationStyle = .pageSheet
                    }
                    topController.present(customerWebViewVC, animated: true, completion: nil)
                } else if page_type as? String == Constants.BOTTOM_DEFAULT_NOTIFICATION {
                    let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
                    customerWebViewVC.urlStr = nudge_url as? String ?? ""
                    customerWebViewVC.notificationHandler = true
                    customerWebViewVC.isbottomdefault = true
                    customerWebViewVC.alpha = backgroundAlpha
                    customerWebViewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    customerWebViewVC.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    guard let topController = UIViewController.topViewController() else {
                        return
                    }
                    topController.present(customerWebViewVC, animated: false, completion: nil)
                } else if page_type as? String == Constants.MIDDLE_NOTIFICATIONS {
                    let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
                    customerWebViewVC.urlStr = nudge_url as? String ?? ""
                    customerWebViewVC.notificationHandler = true
                    customerWebViewVC.modalPresentationStyle = .overCurrentContext
                    customerWebViewVC.ismiddle = true
                    customerWebViewVC.alpha = backgroundAlpha
                    guard let topController = UIViewController.topViewController() else {
                        return
                    }
                    topController.present(customerWebViewVC, animated: false, completion: nil)
                } else {
                    let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
                    customerWebViewVC.urlStr = nudge_url as? String ?? ""
                    customerWebViewVC.notificationHandler = true
                    customerWebViewVC.modalPresentationStyle = .fullScreen
                    customerWebViewVC.alpha = backgroundAlpha
                    guard let topController = UIViewController.topViewController() else {
                        return
                    }
                    topController.present(customerWebViewVC, animated: false, completion: nil)
                }
            } else {
                //                if UIApplication.shared.applicationState == .active {
                //                    var localNotification = UILocalNotification()
                //                    localNotification.userInfo = userInfo
                //                    localNotification.soundName = UILocalNotificationDefaultSoundName
                //                    localNotification.alertBody = "abcd"
                //                    localNotification.fireDate = Date()
                //                    UIApplication.shared.scheduleLocalNotification(localNotification)
                //                }
                print("Local Notification")
                return
            }
        } else {
        }
    }
    
    public func displayBackgroundNotification(remoteMessage: [String: AnyHashable]) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        let nudge_url = remoteMessage[NotificationsKey.nudge_url]
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.urlStr = nudge_url as? String ?? ""
        customerWebViewVC.notificationHandler = true
        customerWebViewVC.modalPresentationStyle = .fullScreen
        guard let topController = UIViewController.topViewController() else {
            return
        }
        topController.present(customerWebViewVC, animated: false, completion: nil)
    }
    
    public func notificationFromCustomerGlu(remoteMessage: [String: AnyHashable]) -> Bool {
        let strType = remoteMessage[NotificationsKey.type] as? String
        if strType == NotificationsKey.CustomerGlu {
            //            if (remoteMessage["glu_message_type"] as? String) == "in-app" {
            //                return true
            //            } else {
            //                return false
            //            }
            return true
        } else {
            return false
        }
    }
    
    public func doValidateToken() -> Bool {
        if userDefaults.object(forKey: Constants.CUSTOMERGLU_TOKEN) != nil {
            let arr = JWTDecode.shared.decode(jwtToken: userDefaults.string(forKey: Constants.CUSTOMERGLU_TOKEN) ?? "")
            let expTime = Date(timeIntervalSince1970: (arr["exp"] as? Double)!)
            let currentDateTime = Date()
            if currentDateTime < expTime {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    public func clearCustomerGluData() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    // MARK: - API Calls Methods
    public func registerDevice(userdata: [String: AnyHashable], completion: @escaping (Bool, RegistrationModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
            userData[APIParameterKey.deviceId] = uuid
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let writekey = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String
        userData[APIParameterKey.deviceType] = "ios"
        userData[APIParameterKey.deviceName] = getDeviceName()
        userData[APIParameterKey.appVersion] = appVersion
        userData[APIParameterKey.writeKey] = writekey
        
        if CustomerGlu.fcm_apn == "fcm" {
            userData["apnsDeviceToken"] = ""
        } else {
            userData["firebaseToken"] = ""
        }
        
        APIManager.userRegister(queryParameters: userData as NSDictionary) { result in
            switch result {
            case .success(let response):
                if response.success! {
                    self.userDefaults.set(response.data?.token, forKey: Constants.CUSTOMERGLU_TOKEN)
                    self.userDefaults.set(response.data?.user?.userId, forKey: Constants.CUSTOMERGLU_USERID)
                    completion(true, response)
                } else {
                    DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "doRegister", exception: "Not found")
                }
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "doRegister", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func updateProfile(userdata: [String: AnyHashable], completion: @escaping (Bool, RegistrationModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
            userData[APIParameterKey.deviceId] = uuid
        }
        let user_id = userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID)
        if user_id == nil && user_id?.count ?? 0 < 0 {
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
            userData["apnsDeviceToken"] = ""
            userData["firebaseToken"] = fcmToken
        } else {
            userData["firebaseToken"] = ""
            userData["apnsDeviceToken"] = apnToken
        }

        APIManager.userRegister(queryParameters: userData as NSDictionary) { result in
            switch result {
            case .success(let response):
                if response.success! {
                    self.userDefaults.set(response.data?.token, forKey: Constants.CUSTOMERGLU_TOKEN)
                    self.userDefaults.set(response.data?.user?.userId, forKey: Constants.CUSTOMERGLU_USERID)
                    completion(true, response)
                } else {
                    DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "doRegister", exception: "Not found")
                }
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "doRegister", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func openWallet(completion: @escaping (Bool, CampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        APIManager.getWalletRewards(queryParameters: [:]) { result in
            switch result {
            case .success(let response):
                self.campaigndata = response
                do {
                    try self.userDefaults.setObject(self.campaigndata, forKey: Constants.WalletRewardData)
                } catch {
                    print(error.localizedDescription)
                }
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "openWallet", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func loadAllCampaigns(completion: @escaping (Bool, CampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        APIManager.getWalletRewards(queryParameters: [:]) { result in
            switch result {
            case .success(let response):
                self.campaigndata = response
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "loadAllCampaigns", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func loadCampaignById(campaign_id: String, completion: @escaping (Bool, CampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        let parameters = [
            "campaign_id": campaign_id
        ]
        APIManager.getWalletRewards(queryParameters: parameters as NSDictionary) { result in
            switch result {
            case .success(let response):
                self.campaigndata = response
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "loadCampaignById", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func loadCampaignsByType(type: String, completion: @escaping (Bool, CampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        let parameters = [
            "type": type
        ]
        APIManager.getWalletRewards(queryParameters: parameters as NSDictionary) { result in
            switch result {
            case .success(let response):
                self.campaigndata = response
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "loadCampaignsByType", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func loadCampaignByStatus(status: String, completion: @escaping (Bool, CampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        let parameters = [
            "status": status
        ]
        APIManager.getWalletRewards(queryParameters: parameters as NSDictionary) { result in
            switch result {
            case .success(let response):
                self.campaigndata = response
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "loadCampaignByStatus", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func loadCampaignByFilter(parameters: NSDictionary, completion: @escaping (Bool, CampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        APIManager.getWalletRewards(queryParameters: parameters) { result in
            switch result {
            case .success(let response):
                self.campaigndata = response
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "loadCampaignByFilter", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func sendEventData(eventName: String, eventProperties: [String: Any], completion: @escaping (Bool, AddCartModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        let date = Date()
        let event_id = UUID().uuidString
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = Constants.DATE_FORMAT
        let timestamp = dateformatter.string(from: date)
      //  let evp = String(describing: eventProperties)
        let user_id = userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID)
        
        let eventData = [
            APIParameterKey.event_id: event_id,
            APIParameterKey.event_name: eventName,
            APIParameterKey.user_id: user_id ?? "",
            APIParameterKey.timestamp: timestamp,
            APIParameterKey.event_properties: eventProperties] as [String: Any]
        
        APIManager.addToCart(queryParameters: eventData as NSDictionary) { result in
            switch result {
            case .success(let response):
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "addToCart", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    private func crashReport(parameters: NSDictionary, completion: @escaping (Bool, AddCartModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        APIManager.crashReport(queryParameters: parameters) { result in
            switch result {
            case .success(let response):
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "crashReport", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
}
