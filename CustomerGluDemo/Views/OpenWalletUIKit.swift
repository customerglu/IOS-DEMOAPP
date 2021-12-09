//
//  OpenWalletUIKit.swift
//  CustomerGluDemo
//
//  Created by kapil on 03/11/21.
//

import Foundation
import SwiftUI
import CustomerGlu

struct OpenWalletUIKit: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        CustomerGlu.disableSDK = true
        let openWalletVC = OpenWalletViewController.storyboardVC
        return openWalletVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

    }
}
