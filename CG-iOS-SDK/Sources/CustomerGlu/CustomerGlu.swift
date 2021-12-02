import Foundation
import SwiftUI
import UIKit

let gcmMessageIDKey = "gcm.message_id"

public class CustomerGlu: NSObject {
    
    // Singleton Instance
    public static var single_instance = CustomerGlu()
    
    private override init() {
        NSSetUncaughtExceptionHandler { exception in
            if exception.reason != nil {
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: exception.reason!.replace(string: ",", replacement: " "), code: exception.callStackSymbols.description.replace(string: ",", replacement: " "))
            } else {
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "Unknown", code: exception.callStackSymbols.description.replace(string: ",", replacement: " "))
            }
        }
    }
    
    @Published var campaigndata = CampaignsModel()
    
    private func getDeviceName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    private func getReferralId(deepLink: URL) -> String {
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let referrerUserId = queryItems?.filter({(item) in item.name == APIParameterKey.userId}).first?.value
        return referrerUserId ?? ""
    }
    
    public func cgUserNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Change this to your preferred presentation option
        if CustomerGlu.single_instance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
            if userInfo[NotificationsKey.glu_message_type] as? String == "push" {
                if UIApplication.shared.applicationState == .active {
                    completionHandler([[.alert, .badge, .sound]])
                }
            }
        }
    }
    
    public func cgapplication(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], backgroundAlpha: Double = 0.5, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if CustomerGlu.single_instance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? [NotificationsKey.customerglu: "d"]) {
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
        if UserDefaults.standard.object(forKey: Constants.CUSTOMERGLU_TOKEN) != nil {
            let arr = JWTDecode.shared.decode(jwtToken: UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN) ?? "")
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
    
    public func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    // MARK: - API Calls Methods
    public func doRegister(body: [String: AnyHashable], completion: @escaping (Bool, RegistrationModel?) -> Void) {
        
        var userdata = body
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
            userdata[APIParameterKey.deviceId] = uuid
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let writekey = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String
        userdata[APIParameterKey.deviceType] = "ios"
        userdata[APIParameterKey.deviceName] = getDeviceName()
        userdata[APIParameterKey.appVersion] = appVersion
        userdata[APIParameterKey.writeKey] = writekey
        
        APIManager.userRegister(queryParameters: userdata as NSDictionary) { result in
            switch result {
            case .success(let response):
                if response.success! {
                    UserDefaults.standard.set(response.data?.token, forKey: Constants.CUSTOMERGLU_TOKEN)
                    UserDefaults.standard.set(response.data?.user?.userId, forKey: Constants.CUSTOMERGLU_USERID)
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
    
    public func getWalletRewards(completion: @escaping (Bool, CampaignsModel?) -> Void) {
        APIManager.getWalletRewards(queryParameters: [:]) { result in
            switch result {
            case .success(let response):
                self.campaigndata = response
                let userDefaults = UserDefaults.standard
                do {
                    try userDefaults.setObject(self.campaigndata, forKey: Constants.WalletRewardData)
                } catch {
                    print(error.localizedDescription)
                }
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "getWalletRewards", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func addToCart(eventName: String, eventProperties: [String: Any], completion: @escaping (Bool, AddCartModel?) -> Void) {
        
        let date = Date()
        let event_id = UUID().uuidString
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = Constants.DATE_FORMAT
        let timestamp = dateformatter.string(from: date)
        let evp = String(describing: eventProperties)
        let user_id = UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)
        print(evp)
        
        let eventData = [
            APIParameterKey.event_id: event_id,
            APIParameterKey.event_name: eventName,
            APIParameterKey.user_id: user_id,
            APIParameterKey.timestamp: timestamp,
            APIParameterKey.event_properties: evp]
        
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
}
