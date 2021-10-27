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
    
    var constant = Constants()
    @available(iOS 13.0, *)
    public init() {
    }
    
    var text = "Hello World !"
    @Published var apidata = RegistrationModel()
    @Published var campaigndata = CampaignsModel()
    
    func machineName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    public func doRegister(body: [String: AnyHashable], completion: @escaping (RegistrationModel) -> Void) {
        var userdata = body
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
            userdata["deviceId"] = uuid
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let writekey = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String
        userdata["deviceType"] = "ios"
        let modelname = machineName()
        userdata["deviceName"] = modelname
        userdata["appVersion"] = appVersion
        userdata["writeKey"] = writekey
        
        print(machineName())
        
        let jsonData = try? JSONSerialization.data(withJSONObject: userdata, options: .fragmentsAllowed)
        
        let myurl = URL(string: self.constant.DEVICE_REGISTER)
        var request = URLRequest(url: myurl!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(response as Any)
            if error == nil && data != nil {
                do {
                    let dictonary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any]
                    print(dictonary as Any)
                    do {
                        let mydata = try JSONDecoder().decode(RegistrationModel.self, from: data!)
                        print("data")
                        print("-------------------")
                        DispatchQueue.main.async {
                            self.apidata = mydata
                            let token = self.apidata.data?.token
                            UserDefaults.standard.set(token, forKey: self.constant.CUSTOMERGLU_TOKEN)
                            let user_id = self.apidata.data?.token
                            UserDefaults.standard.set(user_id, forKey: self.constant.CUSTOMERGLU_USERID)
                            completion(self.apidata)
                        }
                    } catch {
                        print(self.constant.JSON_ERROR + "\(error)")
                    }
                } catch {
                    print(self.constant.ERROR + "\(error)")
                }
            }
        }.resume()
    }
    
    public func retrieveData(customer_token: String, completion: @escaping (CampaignsModel) -> Void) {
        
        let token = "Bearer "+customer_token
        let myurl = URL(string: self.constant.LOAD_CAMPAIGNS)
        var request = URLRequest(url: myurl!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(response as Any)
            if error == nil && data != nil {
                do {
                    let mydata = try JSONDecoder().decode(CampaignsModel.self, from: data!)
                    print("data")
                    DispatchQueue.main.async {
                        self.campaigndata = mydata
                        completion(self.campaigndata)
                        print(self.campaigndata)
                    }
                } catch {
                    print(self.constant.ERROR + "\(error)")
                }
            }
        }.resume()
    }
    
    public func openUiKitWallet() {
        let swiftUIView = OpenUiKitWallet()
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        //       self.navigationController?.pushViewController(hostingController, animated: true)
        guard let topController = UIViewController.topViewController() else {
            return
        }
        topController.present(hostingController, animated: true, completion: nil)
    }
    
    public func loadAllCampaignsUiKit() {
        let swiftUIView = LoadCampaignsUiKit()
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        //       self.navigationController?.pushViewController(hostingController, animated: true)
        guard let topController = UIViewController.topViewController() else {
            return
        }
        topController.present(hostingController, animated: true, completion: nil)
    }
    
    public func getReferralId(deepLink: URL) -> String {
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let referrerUserId = queryItems?.filter({(item) in item.name == "userId"}).first?.value
        return referrerUserId ?? ""
    }
    
    public func displayNotification(remoteMessage: [String: AnyHashable]) {
        
        let nudge_url = remoteMessage["nudge_url"]
        print(nudge_url as Any)
        let notification_type = remoteMessage["notification_type"]
        
        if (remoteMessage["glu_message_type"] as? String) == "in-app" {
            print(notification_type as Any)
            
            if notification_type as? String == self.constant.BOTTOM_SHEET_NOTIFICATION {
                let swiftUIView = NotificationHandler(my_url: nudge_url as? String ?? "")
                let hostingController = UIHostingController(rootView: swiftUIView)
                //      hostingController.modalPresentationStyle = .fullScreen
                guard let topController = UIViewController.topViewController() else {
                    return
                }
                topController.present(hostingController, animated: true, completion: nil)
            } else if notification_type as? String == self.constant.BOTTOM_DEFAULT_NOTIFICATION {
                let swiftUIView = NotificationHandler(my_url: nudge_url as? String ?? "")
                let hostingController = UIHostingController(rootView: swiftUIView)
                //     hostingController.modalPresentationStyle = .overFullScreen
                hostingController.isModalInPresentation = true
                
                guard let topController = UIViewController.topViewController() else {
                    return
                }
                topController.present(hostingController, animated: true, completion: nil)
                
            } else if notification_type as? String == self.constant.MIDDLE_NOTIFICATIONS {
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
        
        let nudge_url = remoteMessage["nudge_url"]
        let swiftUIView = NotificationHandler(my_url: nudge_url as? String ?? "")
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        guard let topController = UIViewController.topViewController() else {
            return
        }
        topController.present(hostingController, animated: true, completion: nil)
    }
    
    public func notificationFromCustomerGlu(remoteMessage: [String: AnyHashable]) -> Bool {
        
        let strType = remoteMessage["type"] as? String
        if strType == "CustomerGlu" {
            if (remoteMessage["glu_message_type"] as? String) == "in-app" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    public func sendEvents(eventName: String, eventProperties: [String: Any]) {
        let date = Date()
        let event_id = UUID().uuidString
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = self.constant.DATE_FORMAT
        let timestamp = dateformatter.string(from: date)
        let evp = String(describing: eventProperties)
        let user_id = UserDefaults.standard.string(forKey: self.constant.CUSTOMERGLU_USERID)
        print(evp)
        
        let eventData = [
            "event_id": event_id,
            "event_name": eventName,
            "user_id": user_id,
            "timestamp": timestamp,
            "event_properties": evp]
        
        let writekey = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String
        let jsonData = try? JSONSerialization.data(withJSONObject: eventData, options: .fragmentsAllowed)
        print(jsonData as Any)
        let myurl = URL(string: self.constant.SEND_EVENTS)
        var request = URLRequest(url: myurl!)
        request.httpMethod="POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(writekey, forHTTPHeaderField: "x-api-key")
        //  request.httpBody = eventData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(response as Any)
            if error == nil && data != nil {
                do {
                    let dictonary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    as? [String: Any]
                    print(dictonary as Any)
                } catch {
                    print(self.constant.ERROR + "\(error)")
                }
            }
        }.resume()
    }
}
