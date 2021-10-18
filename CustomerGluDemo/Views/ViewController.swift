//
//  ViewController.swift
//  CustomerGluDemo
//
//  Created by Himanshu Trehan on 03/08/21.
//

import Foundation
import UIKit
import SwiftUI
import CustomerGlu
import WebKit
//storyboard to swiftUI


class ViewController: UIViewController,WKNavigationDelegate,WKScriptMessageHandler
{
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        let config = WKWebViewConfiguration()
//        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
//
//             config.userContentController.addUserScript(script)
          config.userContentController.add(self, name: "callback")

          let webView = WKWebView(frame: view.frame, configuration: config)

          view.addSubview(webView)
//        webView.loadHTMLString(scriptSource, baseURL: nil)
        let url = URL(string: "https://7oy1x.csb.app/")!
        let req = URLRequest(url: url)
          webView.load(req) //load your html body here

      }

      func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
           let body = message.body as? String
        print(body ?? "ds")
          
      }
    }
    
//    @IBAction func OpenSwift(_ sender: Any) {
//        print("connected")
//        CustomerGlu().loadAllCampaignsUiKit()
//    }
//
//    @IBAction func wallet(_ sender: UIButton) {
//        CustomerGlu().openUiKitWallet()
//    }
    
//    func presentSwiftUIView(view:AnyView) {
//
//        let swiftUIView = OpenWallet(cus_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJnbHUiLCJnbHVJZCI6IjIzZmRkOWU0LWRjYWMtNDlkYS1hMWI5LThmYWRjOGU2YWZkNSIsImNsaWVudCI6Ijg0YWNmMmFjLWIyZTAtNDkyNy04NjUzLWNiYTJiODM4MTZjMiIsImRldmljZUlkIjoiZGV2aWNlYiIsImRldmljZVR5cGUiOiJhbmRyb2lkIiwiaWF0IjoxNjI4MDY0NzYxLCJleHAiOjE2NTk2MDA3NjF9.x86E0pKN2n_nc_If6nqL3CsxGql78q4ehtgwbUdaAwg")
//    //UIHostingController
////        UINavigationController(rootViewController: UIViewController)
//        let hostingController = UIHostingController(rootView: swiftUIView)
//        hostingController.modalPresentationStyle = .fullScreen
//
////       self.navigationController?.pushViewController(hostingController, animated: true)
//
//        UIApplication.keyWin?.rootViewController?.present(hostingController, animated: true, completion: nil)
//
//    }
    
 
    
    

