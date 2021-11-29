//
//  AppDelegate.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 17/08/21.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseAnalytics
import CustomerGlu

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func handleDynamicLink(_ dynamicLink: DynamicLink) {
        print("my dynamic url")
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks() .handleUniversalLink(userActivity.webpageURL!) { dynamiclink, error in
            print(error as Any)
            print(dynamiclink as Any)
            if dynamiclink != nil {
                self.handleDynamicLink(dynamiclink!)
            }
        }
        if handled {
            return true
        } else {
            return false
        }
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("com.myApp") == .orderedSame,
            let view = url.host {
            
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            
           // redirect(to: view, with: parameters)
        }
        return true
    }
    
//    @available(iOS 9.0, *)
//    func application(_ app: UIApplication, open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
//        return application(app, open: url,
//                           sourceApplication: options[UIApplication.OpenURLOptionsKey
//                                                        .sourceApplication] as? String, annotation: "")
//    }
//
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
//                     annotation: Any) -> Bool {
//        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
//            // Handle the deep link. For example, show the deep-linked content or
//            // apply a promotional offer to the user's account.
//            // ...
//            print("dynamic")
//            print(dynamicLink)
//            return true
//        }
//        return false
//    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
            /// some
        }
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
   
        print(userInfo)
        CustomerGlu.single_instance.cgapplication(application, didReceiveRemoteNotification: userInfo, backgroundAlpha: 0.15, fetchCompletionHandler: completionHandler)
 //        if let messageID = userInfo[gcmMessageIDKey] {
 //            print("Message ID: \(messageID)")
 //        }
 //        print("usernotification wqq")
 //
 //        print(userInfo)
 ////        CustomerGlu.single_instance.displayNotification(remoteMessage: userInfo as? [String: AnyHashable] ?? ["xz": "d"])
 //        if CustomerGlu.single_instance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? ["customerglu": "d"]) {
 //            CustomerGlu.single_instance.displayNotification(remoteMessage: userInfo as? [String: AnyHashable] ?? ["customerglu": "d"])
 //        } else {
 //            completionHandler(UIBackgroundFetchResult.newData)
 //        }
 //        // completionHandler(UIBackgroundFetchResult.newData)
     }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let _:[String: String] = ["token": fcmToken ?? ""]
        print("Device token: ", fcmToken ?? "fcm")
        // This token can be used for testing notifications on FCM
        UserDefaults.standard.set(fcmToken, forKey: "fcmtoken")
        let fcmRegTokenMessage = UserDefaults.standard.string(forKey: "fcmtoken")
        print(fcmRegTokenMessage as Any)
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

//        let userInfo = notification.request.content.userInfo
//
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        print("usernotification ")
//        print(userInfo)
//        // print(userInfo["data"] as Any)
//
//        if CustomerGlu.single_instance.notificationFromCustomerGlu(remoteMessage: userInfo as? [String: AnyHashable] ?? ["customerglu": "d"]) {
//            CustomerGlu.single_instance.displayNotification(remoteMessage: userInfo as? [String: AnyHashable] ?? ["customerglu": "d"])
//        } else {
//            completionHandler([[.banner, .badge, .sound]])
//        }
//        // Change this to your preferred presentation option

        CustomerGlu.single_instance.cgUserNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        print("APNS")
        //   print(Messaging.messaging().apnsToken)
        print("APNs token retrieved: \(deviceToken)")
        //     UserDefaults.standard.set(devToken, forKey: "fcmtoken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID from userNotificationCenter didReceive: \(messageID)")
        }
        print("background click")
        print(userInfo)
        CustomerGlu.single_instance.displayBackgroundNotification(remoteMessage: userInfo["data"] as? [String: AnyHashable] ?? ["glu_message_type": "glu"])
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print(fcmToken)
    }
}
