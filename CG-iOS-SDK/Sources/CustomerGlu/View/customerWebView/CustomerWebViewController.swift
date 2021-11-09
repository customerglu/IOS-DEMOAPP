//
//  File.swift
//  
//
//  Created by kapil on 09/11/21.
//

import Foundation
import UIKit
import WebKit

class CustomerWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
        
    var webView = WKWebView()
    var urlStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "callback") //name is the key you want the app to listen to.
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), configuration: config) //set your own frame
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: urlStr )!))
        self.view.addSubview(webView)
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
    
    // receive message from wkwebview
    public func userContentController(
        _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
        print(message.name)
        print(message)
        print("Body message", message.body)
        if message.name == "callback" {
            guard let bodyString = message.body as? String,
                  let bodyData = bodyString.data(using: .utf8) else { fatalError() }
            
            let bodyStruct = try? JSONDecoder().decode(EventModel.self, from: bodyData)
            
            if bodyStruct?.eventName == "CLOSE" {
                print("close")
//                if parent.fromWallet && parent.fromUikit {
                    print("UIKIT")
//                    guard let topController = UIViewController.topViewController() else {
//                        return
//                    }
                    self.navigationController?.popToRootViewController(animated: true)
//                    topController.dismiss(animated: true, completion: nil)
                    //   UIApplication.keyWin?.rootViewController?.dismiss(animated: true, completion: nil)
//                } else {
//                    print("SwiftUI")
//                    parent.presentation.wrappedValue.dismiss()
//                }
            }
            
            if bodyStruct?.eventName == "OPEN_DEEPLINK" {
                let deeplink = try? JSONDecoder().decode(DeepLinkModel.self, from: bodyData)
                if  let deep_link = deeplink?.data?.deepLink {
                    print("link", deep_link)
                    if let url = URL(string: deep_link) {
                        UIApplication.shared.open(url)
                    } else {
                        DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "", exception: "Can't open deeplink")
                        print("Can't open deeplink")
                    }
                }
            }
            
            if bodyStruct?.eventName == "SHARE" {
                let share = try? JSONDecoder().decode(EventShareModel.self, from: bodyData)
                if let text = share?.data?.text {
                    print("text", text)
                    if let url = URL(string: "whatsapp://send?text=\(text)") {
                        UIApplication.shared.open(url)
                    } else {
                        DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "", exception: "Can't open whatsapp")
                        print("Can't open whatsapp")
                    }
                }
            }
        }
    }
}
