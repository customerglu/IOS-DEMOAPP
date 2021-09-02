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

      completionHandler(UIBackgroundFetchResult.newData)
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

//    if (CustomerGlu().notificationFromCustomerGlu(remoteMessage: userInfo["data"]as? [String:AnyHashable] ?? ["customerglu":"d"]))
//    {
//    CustomerGlu().displayNotification(remoteMessage: userInfo["data"]as? [String:AnyHashable] ?? ["customerglu":"d"])
//    }
//    else
//    {
//        completionHandler([[.banner, .badge, .sound]])
//
//    }

//    let msgdata = userInfo["aps"] as? [String:AnyHashable]
//    let myalert = msgdata?["alert"] as? [String:AnyHashable]
//    let Type = myalert?["type"]
//    if Type as! String == "CustomerGlu"
//    {
//        print("CustomerGlu")
//        CustomerGlu().openUiKitWallet(cus_token: "s")
//
//    }
    
    
    

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
    CustomerGlu().displayBackgroundNotification(remoteMessage: userInfo["data"]as? [String:AnyHashable] ?? ["xz":"d"])

    completionHandler()
  }
}
