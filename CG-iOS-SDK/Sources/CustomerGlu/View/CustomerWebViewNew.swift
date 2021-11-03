//
//  File.swift
//  
//
//  Created by kapil on 02/11/21.
//

import Foundation
import UIKit
import WebKit

class CustomerWebViewNew: UIView, WKNavigationDelegate {
    
    var webView = WKWebView()
    var urlStr: String?

    //initWithFrame to init view from code
    init(url: String) {
        self.urlStr = url
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: urlStr ?? "")!))
        self.addSubview(webView)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Started to load")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished loading")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
}
