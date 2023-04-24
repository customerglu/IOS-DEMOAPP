//
//  CustomerGluDemoApp.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI
import UIKit
import CustomerGluRN
@main
struct CustomerGluDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            
            let token = UserDefaults.standard.object(forKey: "CustomerGlu_Token_Encrypt") as? String ?? ""
                
            let uid = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: "CustomerGlu_user_id_Encrypt")
            let uanonid = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: "CustomerGluAnonymousId_Encrypt")
            
            if (token.count > 0 && uid.count > 0 && ((uanonid.count <= 0) || (uid != uanonid))) {

                HomeScreen()
                    .onOpenURL { url in
                        // URL handling
//                        { success in
//                            if success {
//                                self.isActive = true
//                            } else {
//                                self.attemptingLogin = false
//                                print("error")
//                            }
//                        }
                        CustomerGlu.getInstance.openDeepLink(deepurl: url){
                            success, string, deeplinkdata in
                            
                        }
                        print(url)
                        if let scheme = url.scheme,
                            scheme.localizedCaseInsensitiveCompare("https") == .orderedSame,
                            let view = url.host {

                            var parameters: [String: String] = [:]
                            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                                parameters[$0.name] = $0.value
                            }

                           // redirect(to: view, with: parameters)
                        }
                    }
            } else {
                LoginScreen()
                    .onOpenURL { url in
                        // URL handling
                        CustomerGlu.getInstance.openDeepLink(deepurl: url){
                            success, string, deeplinkdata in
                            
                        }
                        print(url)
                        if let scheme = url.scheme,
                            scheme.localizedCaseInsensitiveCompare("https") == .orderedSame,
                            let view = url.host {

                            var parameters: [String: String] = [:]
                            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                                parameters[$0.name] = $0.value
                            }

                           // redirect(to: view, with: parameters)
                        }
                    }
            }
        }
    }
    
    func handleURL(_ url: URL) {
        print(url)
    }
}
