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

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        //        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
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
