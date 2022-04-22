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
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            // Handle URL
            print(url)
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey
                                                        .sourceApplication] as? String, annotation: "")
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
                     annotation: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            print("dynamic")
            print(dynamicLink)
            return true
        }
        return false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        CustomerGlu.getInstance.disableGluSdk(disable: false)
        CustomerGlu.getInstance.isFcmApn(fcmApn: "fcm")
        CustomerGlu.getInstance.setDefaultBannerImage(bannerUrl: "https://assets.customerglu.com/demo/quiz/banner-image/Quiz_2.png")
        CustomerGlu.getInstance.configureLoaderColour(color: [UIColor.red])
//        CustomerGlu.getInstance.enableDebugging(enabled: true)
        CustomerGlu.getInstance.enableEntryPoint(enabled: true)

        
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
        CustomerGlu.getInstance.cgapplication(application, didReceiveRemoteNotification: userInfo, backgroundAlpha: 0.5, fetchCompletionHandler: completionHandler)
     }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        CustomerGlu.getInstance.fcmToken = fcmToken ?? ""
        
      //  let userData = [String: AnyHashable]()
        
//        CustomerGlu.getInstance.updateProfile(userdata: userData) { success, _ in
//            if success {
//            } else {
//            }
//        }
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Change this to your preferred presentation option
        CustomerGlu.getInstance.cgUserNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) { //apn
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Device token: \(tokenString)")
        CustomerGlu.getInstance.apnToken = tokenString
        
        //firebase
        Messaging.messaging().apnsToken = deviceToken
        print("APNs token retrieved: \(deviceToken)")
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
        print(userInfo)
        CustomerGlu.getInstance.displayBackgroundNotification(remoteMessage: userInfo as? [String: AnyHashable] ?? ["glu_message_type": "glu"])
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print(fcmToken)
    }
}
