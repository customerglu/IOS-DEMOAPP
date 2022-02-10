//
//  RewardUIKit.swift
//  CustomerGluDemo
//
//  Created by kapil on 09/11/21.
//

import Foundation
import SwiftUI
import CustomerGlu

struct RewardUIKit: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let rewardVC = LoadAllCampaignsViewController.storyboardVC
        return rewardVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

    }
}
