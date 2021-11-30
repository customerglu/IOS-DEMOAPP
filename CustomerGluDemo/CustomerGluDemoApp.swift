//
//  CustomerGluDemoApp.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI
import UIKit
@main
struct CustomerGluDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.object(forKey: "CustomerGlu_Token") != nil {
                HomeScreen()
                    .onOpenURL { url in
                        // URL handling
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
            }
        }
    }
    
    func handleURL(_ url: URL) {
        print(url)        
    }
}
