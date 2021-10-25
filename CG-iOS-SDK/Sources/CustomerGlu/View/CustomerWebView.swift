//
//  SwiftUIView.swift
//  
//
//  Created by Himanshu Trehan on 23/07/21.
//

import SwiftUI
import WebKit
import UIKit
@available(iOS 13.0, *)
extension UIApplication{
static var keyWin: UIWindow? {
    
    return UIApplication.shared.windows.first { $0.isKeyWindow }
    
    
}
}
@available(iOS 13.0, *)
public struct CustomerWebView: UIViewRepresentable {
    
    @State var my_url:String
    @State var fromWallet = false
    @State var fromUikit = false
    var token=""
    @Environment(\.presentationMode) var presentation
    
   public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    
        var webView: WKWebView?
    var parent:CustomerWebView
  //  public override init(){}
   // @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  init(parent:CustomerWebView) {
        self.parent = parent
    }
       public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.webView = webView
        }
        
        // receive message from wkwebview
      public  func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
        print(message.name)
        print(message)
        print("Body message",message.body)
                    
        
        if message.name == "callback" {

            guard let bodyString = message.body as? String,
                  let bodyData = bodyString.data(using: .utf8) else { fatalError() }

            let bodyStruct = try? JSONDecoder().decode(EventModel.self, from: bodyData)
           
            if bodyStruct?.eventName == "CLOSE"
            {
                print("close")
                if(parent.fromWallet && parent.fromUikit)
                {
                    print("UIKIT")
                    guard let topController = UIViewController.topViewController() else {
                                                         return
                                                     }
                    topController.dismiss(animated: true, completion: nil)
                 //   UIApplication.keyWin?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                else{
                    print("SwiftUI")
                parent.presentation.wrappedValue.dismiss()
                }

            }
            
            if bodyStruct?.eventName == "OPEN_DEEPLINK" {
                
                let deeplink = try? JSONDecoder().decode(DeepLinkModel.self, from: bodyData)
                if  let deep_link = deeplink?.data?.deepLink
                {
                 print("link",deep_link)
                         if let url = URL(string: deep_link) {
                                UIApplication.shared.open(url)
                                         
                         }
                         else{
                             print("Can't open deeplink")
                         }

                 }
                
            }
            
            if bodyStruct?.eventName == "SHARE" {
                
                let share = try? JSONDecoder().decode(EventShareModel.self, from: bodyData)
           if    let text = share?.data?.text
           {
            print("text",text)
                    if let url = URL(string: "whatsapp://send?text=\(text)") {
                           UIApplication.shared.open(url)
                    }
                    else{
                        print("Can't open whatsapp")
                    }

            }
            }
              
        }
        
     
          }
        
        
//        func messageToWebview(msg: String) {
//
//            self.webView?.evaluateJavaScript("MY message:\(msg)")
//
//        }
    }
    
  public  func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
   public  func makeUIView(context: Context) -> WKWebView  {
        
        let coordinator = makeCoordinator()
          let userContentController = WKUserContentController()
          userContentController.add(coordinator, name: "callback")
          
          let configuration = WKWebViewConfiguration()
          configuration.userContentController = userContentController
          
          let _wkwebview = WKWebView(frame: .zero, configuration: configuration)
          _wkwebview.navigationDelegate = coordinator
          
    return _wkwebview
   }
  public  func updateUIView(_ uiView: WKWebView, context: Context) {
    let test_url = URL(string: my_url)
   
    if(test_url != nil)
    {
    let request = URLRequest(url: test_url!)
        
        uiView.load(request)
    }
    
    
    }
}
