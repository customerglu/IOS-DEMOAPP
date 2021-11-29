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
            } else {
                LoginScreen()
            }
        }
    }
}
