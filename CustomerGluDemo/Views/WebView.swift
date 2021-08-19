//
//  WebView.swift
//  FirstProject
//
//  Created by Himanshu Trehan on 19/07/21.
//

import SwiftUI
import WebKit
struct WebView: UIViewRepresentable {

    let url:URL?
    var webview = WKWebView()
     func makeUIView(context: Context) -> WKWebView  {
//        let prefs = WKWebpagePreferences()
//        prefs.allowsContentJavaScript=true
//        let config = WKWebViewConfiguration()
//        config.defaultWebpagePreferences = prefs
//        let webview = WKWebView(
//            frame: .zero, configuration: config
//        )
        
        return webview
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let myurl = url else
        {
            return
        }
        let request = URLRequest(url: myurl)
        
        uiView.load(request)
        
    }
    
    }


struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://google.com"))
    }
}
