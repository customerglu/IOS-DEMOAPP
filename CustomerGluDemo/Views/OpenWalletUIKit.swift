//
//  OpenWalletUIKit.swift
//  CustomerGluDemo
//
//  Created by kapil on 03/11/21.
//

import Foundation
import SwiftUI
import CustomerGlu

struct OpenWalletUIKit: UIViewRepresentable {
    
//    func makeUIViewController(context: Context) -> UIViewController {
//        let openWalletVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OpenWalletViewController") as? OpenWalletViewController
////        let storyBoard = UIStoryboard(name: "CustomerGlu", bundle: nil)
////        let openWalletVC = storyBoard.instantiateViewController(withIdentifier: "OpenWalletViewController") as? OpenWalletViewController
//        return openWalletVC!
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//
//    }
    
    func makeUIView(context: Context) -> UIView {
        return OpenWalletNew()
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }
}
