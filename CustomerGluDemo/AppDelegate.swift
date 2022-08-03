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

var customerglu = CustomerGlu.getInstance

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func handleDynamicLink(_ dynamicLink:DynamicLink)
    {
        print("my dynamic url");
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      let handled = DynamicLinks.dynamicLinks()
        .handleUniversalLink(userActivity.webpageURL!) { dynamiclink, error in
          print("dynamic")
            print(dynamiclink as Any)
            
            if dynamiclink != nil
            {
                self.handleDynamicLink(dynamiclink!)
            }
        }
        
        
        
        if handled
        {
            return true
        }
        else{
            return false
        }
    }
    
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
      return application(app, open: url,
                         sourceApplication: options[UIApplication.OpenURLOptionsKey
                           .sourceApplication] as? String,
                         annotation: "")
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

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

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }
        print("usernotification wqq")

      print(userInfo)
        customerglu.displayBackgroundNotification(remoteMessage: userInfo as? [String:AnyHashable] ?? ["xz":"d"])
        let fromCustomerGlu = customerglu.notificationFromCustomerGlu(remoteMessage: userInfo as? [String:AnyHashable] ?? ["customerglu":"d"])
        if (fromCustomerGlu) {
            customerglu.displayBackgroundNotification(remoteMessage: userInfo as? [String:AnyHashable] ?? ["customerglu":"d"])
        } else {
            completionHandler(UIBackgroundFetchResult.newData)
        }
     // completionHandler(UIBackgroundFetchResult.newData)
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
        print("hg")
        print(fcmRegTokenMessage as Any)
    }
}
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
    }
    print("usernotification ")
    print(userInfo)
   // print(userInfo["data"] as Any)
      
    let fromCustomerGlu = customerglu.notificationFromCustomerGlu(remoteMessage: userInfo as? [String:AnyHashable] ?? ["customerglu":"d"])
      
    if (fromCustomerGlu){
        customerglu.displayBackgroundNotification(remoteMessage: userInfo as? [String:AnyHashable] ?? ["customerglu":"d"])
    } else {
        completionHandler([[.banner, .badge, .sound]])

    }

    // Change this to your preferred presentation option
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
      customerglu.displayBackgroundNotification(remoteMessage: userInfo["data"]as? [String:AnyHashable] ?? ["glu_message_type":"glu"])

    completionHandler()
    
  }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("-------------")
       print(fcmToken)

    }
}
