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
    public static var fcm_apn = ""
    let userDefaults = UserDefaults.standard
    public var apnToken = ""
    public var fcmToken = ""
    public static var defaultBannerUrl = ""
    public static var arrColor = [UIColor.black]
    
    private override init() {
        super.init()
        CustomerGluCrash.add(delegate: self)
        do {
            // retrieving a value for a key
            if let data = userDefaults.data(forKey: Constants.CustomerGluCrash),
               let crashItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Dictionary<String, Any> {
                ApplicationManager.callCrashReport(stackTrace: (crashItems["callStack"] as? String)!, isException: true, methodName: "CustomerGluCrash")
            }
        } catch {
            print(error)
        }
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
        
    public func disableGluSdk(disable: Bool) {
        CustomerGlu.sdk_disable = disable
    }
    
    public func isFcmApn(fcmApn: String) {
        CustomerGlu.fcm_apn = fcmApn
    }
    
    public func setDefaultBannerImage(bannerUrl: String) {
        CustomerGlu.defaultBannerUrl = bannerUrl
    }
    
    public func configureLoaderColour(color: [UIColor]) {
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
    
    public func getReferralId(deepLink: URL) -> String {
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let referrerUserId = queryItems?.filter({(item) in item.name == APIParameterKey.userId}).first?.value
        return referrerUserId ?? ""
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
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.BOTTOM_SHEET_NOTIFICATION, backgroundAlpha: backgroundAlpha)
                } else if page_type as? String == Constants.BOTTOM_DEFAULT_NOTIFICATION {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.BOTTOM_DEFAULT_NOTIFICATION, backgroundAlpha: backgroundAlpha)
                } else if page_type as? String == Constants.MIDDLE_NOTIFICATIONS {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: backgroundAlpha)
                } else {
                    presentToCustomerWebViewController(nudge_url: (nudge_url as? String)!, page_type: Constants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: backgroundAlpha)
                }
            } else {
                print("Local Notification")
                return
            }
        } else {
        }
    }
    
    private func presentToCustomerWebViewController(nudge_url: String, page_type: String, backgroundAlpha: Double) {
        
        let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
        customerWebViewVC.urlStr = nudge_url
        customerWebViewVC.notificationHandler = true
        customerWebViewVC.alpha = backgroundAlpha
        guard let topController = UIViewController.topViewController() else {
            return
        }
        
        if page_type == Constants.BOTTOM_SHEET_NOTIFICATION {
            customerWebViewVC.isbottomsheet = true
            if #available(iOS 15.0, *) {
                if let sheet = customerWebViewVC.sheetPresentationController {
                    sheet.detents = [ .medium(), .large() ]
                }
            } else {
                customerWebViewVC.modalPresentationStyle = .pageSheet
            }
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
        topController.present(customerWebViewVC, animated: true, completion: nil)
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
            return true
        } else {
            return false
        }
    }
        
    public func clearGluData() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    // MARK: - API Calls Methods
    public func registerDevice(userdata: [String: AnyHashable], completion: @escaping (Bool, RegistrationModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true {
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
                    self.userDefaults.set(response.data?.token, forKey: Constants.CUSTOMERGLU_TOKEN)
                    self.userDefaults.set(response.data?.user?.userId, forKey: Constants.CUSTOMERGLU_USERID)
                    completion(true, response)
                } else {
                    ApplicationManager.callCrashReport(methodName: "registerDevice")
                }
            case .failure(let error):
                print(error)
                ApplicationManager.callCrashReport(stackTrace: error.localizedDescription, methodName: "registerDevice")
                completion(false, nil)
            }
        }
    }
    
    public func updateProfile(userdata: [String: AnyHashable], completion: @escaping (Bool, RegistrationModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        
        var userData = userdata
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
            userData[APIParameterKey.deviceId] = uuid
        }
        let user_id = userDefaults.string(forKey: Constants.CUSTOMERGLU_USERID)
        if user_id == nil {
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
                    self.userDefaults.set(response.data?.token, forKey: Constants.CUSTOMERGLU_TOKEN)
                    self.userDefaults.set(response.data?.user?.userId, forKey: Constants.CUSTOMERGLU_USERID)
                    completion(true, response)
                } else {
                    ApplicationManager.callCrashReport(methodName: "updateProfile")
                }
            case .failure(let error):
                print(error)
                ApplicationManager.callCrashReport(stackTrace: error.localizedDescription, methodName: "updateProfile")
                completion(false, nil)
            }
        }
    }
    
    public func openWallet() {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        
        DispatchQueue.main.async {
            let openWalletVC = StoryboardType.main.instantiate(vcType: OpenWalletViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            openWalletVC.modalPresentationStyle = .fullScreen
            topController.present(openWalletVC, animated: true, completion: nil)
        }
    }
        
    public func loadAllCampaigns() {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    public func loadCampaignById(campaign_id: String) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        
        DispatchQueue.main.async {
            let customerWebViewVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
            guard let topController = UIViewController.topViewController() else {
                return
            }
            customerWebViewVC.modalPresentationStyle = .fullScreen
            customerWebViewVC.iscampignId = true
            customerWebViewVC.campaign_id = campaign_id
            topController.present(customerWebViewVC, animated: false, completion: nil)
        }
    }
   
    public func loadCampaignsByType(type: String) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.loadCampignType = APIParameterKey.type
            loadAllCampign.loadCampignValue = type
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    public func loadCampaignByStatus(status: String) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.loadCampignType = APIParameterKey.status
            loadAllCampign.loadCampignValue = status
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    public func loadCampaignByFilter(parameters: NSDictionary) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        
        DispatchQueue.main.async {
            let loadAllCampign = StoryboardType.main.instantiate(vcType: LoadAllCampaignsViewController.self)
            loadAllCampign.loadByparams = parameters
            guard let topController = UIViewController.topViewController() else {
                return
            }
            let navController = UINavigationController(rootViewController: loadAllCampign)
            navController.modalPresentationStyle = .fullScreen
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    public func sendEventData(eventName: String, eventProperties: [String: Any]) {
        if CustomerGlu.sdk_disable! == true || Reachability.shared.isConnectedToNetwork() != true {
            print(CustomerGlu.sdk_disable!)
            return
        }

        ApplicationManager.sendEventData(eventName: eventName, eventProperties: ["state": "1"]) { success, addCartModel in
            if success {
                print(addCartModel as Any)
            } else {
                print("error")
            }
        }
    }
}
