//
//  CustomerWebviewUIKit.swift
//  CustomerGluDemo
//
//  Created by kapil on 15/11/21.
//

import Foundation
import SwiftUI
import CustomerGlu

struct CustomerWebviewUIKit: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let customerWebview = CustomerWebViewController.storyboardVC
        customerWebview.alpha = 0.0
        customerWebview.urlStr = "https://dbtailwi34eql.cloudfront.net/reward/?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJoaXRlc2gxMSIsImdsdUlkIjoiN2YyNTU5NDctMGE4Ny00MTYzLWFiOTAtNzNmNzIyZjc1NDgyIiwiY2xpZW50IjoiODRhY2YyYWMtYjJlMC00OTI3LTg2NTMtY2JhMmI4MzgxNmMyIiwiZGV2aWNlSWQiOiI5QzBBQzlGRC03OUVDLTQ4NjktOTVBNC1DN0EwM0Q3OTg3N0IiLCJkZXZpY2VUeXBlIjoiaW9zIiwiaWF0IjoxNjM2OTY3MjgyLCJleHAiOjE2Njg1MDMyODJ9.gv2mEXwaGnfXWRKf5tIvP-zvHk2vpogKOtvlxoV6uR0&rewardUserId=bb5e159c-c0fd-4943-874b-d5a8b92208ab"
        return customerWebview
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

    }
}
