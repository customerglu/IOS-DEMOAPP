//
//  ContentView.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 20/07/21.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        InboxNavigator(storyboardId: "ViewController")
    }
}

struct InboxNavigator: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    var storyboardId: String?
    var storyboardName: String
    
    init(storyboardName: String = "Register", storyboardId: String) {
        self.storyboardId = storyboardId
        self.storyboardName = storyboardName
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<InboxNavigator>) -> InboxNavigator.UIViewControllerType {
        
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController: UIViewController = storyboard.instantiateViewController(identifier: storyboardId!)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: InboxNavigator.UIViewControllerType, context: UIViewControllerRepresentableContext<InboxNavigator>) {
    }
}
