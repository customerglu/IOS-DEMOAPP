import Foundation
import SwiftUI
import UIKit
@available(iOS 13.0, *)

extension UIViewController {
    static func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

@available(iOS 13.0, *)
public class CustomerGlu: ObservableObject {
    
    // Singleton Instance
    public static var single_instance = CustomerGlu()
           
    @available(iOS 13.0, *)
    private init() {
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
    
    public func displayNotification(remoteMessage: [String: AnyHashable]) {
        let nudge_url = remoteMessage[NotificationsKey.nudge_url]
        print(nudge_url as Any)
        let notification_type = remoteMessage[NotificationsKey.notification_type]
        
        if (remoteMessage[NotificationsKey.glu_message_type] as? String) == NotificationsKey.in_app {
            print(notification_type as Any)
            
            if notification_type as? String == Constants.BOTTOM_SHEET_NOTIFICATION {
                let swiftUIView = NotificationHandler(my_url: nudge_url as? String ?? "")
                let hostingController = UIHostingController(rootView: swiftUIView)
                //      hostingController.modalPresentationStyle = .fullScreen
                guard let topController = UIViewController.topViewController() else {
                    return
                }
                topController.present(hostingController, animated: true, completion: nil)
            } else if notification_type as? String == Constants.BOTTOM_DEFAULT_NOTIFICATION {
                let swiftUIView = NotificationHandler(my_url: nudge_url as? String ?? "")
                let hostingController = UIHostingController(rootView: swiftUIView)
                //     hostingController.modalPresentationStyle = .overFullScreen
                hostingController.isModalInPresentation = true
                
                guard let topController = UIViewController.topViewController() else {
                    return
                }
                topController.present(hostingController, animated: true, completion: nil)
                
            } else if notification_type as? String == Constants.MIDDLE_NOTIFICATIONS {
                let swiftUIView = NotificationHandler(my_url: nudge_url as? String ?? "", ismiddle: true)
                
                let hostingController = UIHostingController(rootView: swiftUIView)
                hostingController.modalPresentationStyle = .overCurrentContext
                hostingController.view.backgroundColor = .clear
                
                guard let topController = UIViewController.topViewController() else {
                    return
                }
                topController.present(hostingController, animated: true, completion: nil)
            } else {
                let swiftUIView = NotificationHandler(my_url: nudge_url as? String ?? "")
                
                let hostingController = UIHostingController(rootView: swiftUIView)
                hostingController.modalPresentationStyle = .fullScreen
                guard let topController = UIViewController.topViewController() else {
                    return
                }
                topController.present(hostingController, animated: true, completion: nil)
            }
        } else {
            return
        }
    }
    
    public func displayBackgroundNotification(remoteMessage: [String: AnyHashable]) {
        
        let nudge_url = remoteMessage[NotificationsKey.nudge_url]
        let swiftUIView = NotificationHandler(my_url: nudge_url as? String ?? "")
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        guard let topController = UIViewController.topViewController() else {
            return
        }
        topController.present(hostingController, animated: true, completion: nil)
    }
    
    public func notificationFromCustomerGlu(remoteMessage: [String: AnyHashable]) -> Bool {
        
        let strType = remoteMessage[NotificationsKey.type] as? String
        if strType == NotificationsKey.CustomerGlu {
            if (remoteMessage[NotificationsKey.glu_message_type] as? String) == NotificationsKey.in_app {
                return true
            } else {
                return false
            }
        } else {
            return false
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
