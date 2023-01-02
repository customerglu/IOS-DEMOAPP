//
//  File.swift
//
//
//  Created by kapil on 1/2/22.
//

import UIKit
import Foundation
import WebKit

//EmbedView
public class CGEmbedView: UIView, WKNavigationDelegate, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == WebViewsKey.callback {
            guard let bodyString = message.body as? String,
                  let bodyData = bodyString.data(using: .utf8) else { fatalError() }
            
            let bodyStruct = try? JSONDecoder().decode(CGEventModel.self, from: bodyData)
            
            if bodyStruct?.eventName == WebViewsKey.close {
                embedviewHeightchanged(height: 0.0)
            }
            
            if bodyStruct?.eventName == WebViewsKey.open_deeplink {
                let deeplink = try? JSONDecoder().decode(CGDeepLinkModel.self, from: bodyData)
                if  let deep_link = deeplink?.data?.deepLink {
                    print("link", deep_link)
                    let postdata = OtherUtils.shared.convertToDictionary(text: (message.body as? String)!) ?? [String:Any]()
                    if self.closeOnDeepLink == true{
                        embedviewHeightchanged(height: 0.0)
                    }
                    // Post notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: postdata)
                }
            }
            
            if bodyStruct?.eventName == WebViewsKey.share {
                let share = try? JSONDecoder().decode(CGEventShareModel.self, from: bodyData)
                let text = share?.data?.text
                let channelName = share?.data?.channelName
                if let imageurl = share?.data?.image {
                    if imageurl == "" {
                        if channelName == "WHATSAPP" {
                            sendToWhatsapp(shareText: text!)
                        } else {
                            sendToOtherApps(shareText: text!)
                        }
                    } else {
                        if channelName == "WHATSAPP" {
                            shareImageToWhatsapp(imageString: imageurl, shareText: text ?? "")
                        } else {
                            sendImagesToOtherApp(imageString: imageurl, shareText: text ?? "")
                        }
                    }
                }
            }
            
            if bodyStruct?.eventName == WebViewsKey.analytics {
                if (true == CustomerGlu.analyticsEvent) {
                    let dict = OtherUtils.shared.convertToDictionary(text: (message.body as? String)!)
                    if(dict != nil && dict!.count>0 && dict?["data"] != nil){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_ANALYTICS_EVENT").rawValue), object: nil, userInfo: dict?["data"] as? [String: Any])
                    }
                }
            }
            
            if bodyStruct?.eventName == WebViewsKey.updateheight {
//                if (true == CustomerGlu.analyticsEvent) {
                    let dict = OtherUtils.shared.convertToDictionary(text: (message.body as? String)!)
                    if(dict != nil && dict!.count>0 && dict?["data"] != nil){
                        let dictheight = dict?["data"] as! [String: Any]
                        if(dictheight.count > 0 && dictheight["height"] != nil){
                            finalHeight = (dictheight["height"])! as! Double
                            embedviewHeightchanged(height: finalHeight)
                        }
                    }
//                }
            }
        }
    }
    
    
    var view = UIView()
    var arrContent = [CGContent]()
    var condition : CGCondition?
    private var code = true
    var finalHeight = 0.0
    private var loadedapicalled = false
    
    var webView = WKWebView()
    let contentController = WKUserContentController()
    let config = WKWebViewConfiguration()
    var documentInteractionController: UIDocumentInteractionController!
    public var closeOnDeepLink = CustomerGlu.auto_close_webview!
    
    @IBInspectable var embedId: String? {
        didSet {
            backgroundColor = UIColor.clear
            CustomerGlu.getInstance.postEmbedsCount()
            reloadEmbedView()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.entryPointLoaded),
                name: Notification.Name("EntryPointLoaded"),
                object: nil)
        }
    }
    
    @objc private func entryPointLoaded(notification: NSNotification) {
        self.reloadEmbedView()
    }
    
    var commonEmbedId: String {
        get {
            return self.embedId ?? ""
        }
        set(newWeight) {
            embedId = newWeight
        }
    }
    
    public init(frame: CGRect, embedId: String) {
        //CODE
        super.init(frame: frame)
        code = true
        self.xibSetup()
        self.commonEmbedId = embedId
    }
    
    required init?(coder aDecoder: NSCoder) {
        // XIB
        super.init(coder: aDecoder)
        code = false
        self.xibSetup()
    }
    
    public override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(finalHeight))
    }
    private func shareImageToWhatsapp(imageString: String, shareText: String) {
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    // Set your image's URL into here
                    let url = URL(string: imageString)!
                    data(from: url) { data, response, error in
                        if(true == CustomerGlu.isDebugingEnabled){
                            print(response as Any)
                        }
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async { [weak self] in
                            let image = UIImage(data: data)
                            if let imageData = image!.jpegData(compressionQuality: 1.0) {
                                let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                                do {
                                    try imageData.write(to: tempFile, options: .atomic)
                                    self!.documentInteractionController = UIDocumentInteractionController(url: tempFile)
                                    self!.documentInteractionController.uti = "net.whatsapp.image"
                                    self?.documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: self!.view, animated: true)
                                } catch {
                                    CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "shareImageToWhatsapp", posttoserver: true)
                                }
                            }
                        }
                    }
                } else {
                    CustomerGlu.getInstance.printlog(cglog: "Can't open whatsapp", isException: false, methodName: "shareImageToWhatsapp", posttoserver: true)
                }
            }
        }
    }
    private func sendToOtherApps(shareText: String) {
        // set up activity view controller
        let textToShare = [ shareText ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        // present the view controller
        guard let topController = UIViewController.topViewController() else {
            return
        }
        topController.present(activityViewController, animated: true, completion: nil)
    }
    
    
    private func sendToWhatsapp(shareText: String) {
        let urlWhats = "whatsapp://send?text=\(shareText)"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    UIApplication.shared.open(whatsappURL)
                } else {
                    CustomerGlu.getInstance.printlog(cglog: "Can't open whatsapp", isException: false, methodName: "sendToWhatsapp", posttoserver: true)
                }
            }
        }
    }
    
    private func sendImagesToOtherApp(imageString: String, shareText: String) {
        // Set your image's URL into here
        let url = URL(string: imageString)!
        data(from: url) { data, response, error in
            if(true == CustomerGlu.isDebugingEnabled){
                print(response as Any)
            }
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async { [weak self] in
                if let image = UIImage(data: data) {
                    // set up activity view controller
                    let imageToShare = [shareText, image] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityViewController.popoverPresentationController?.sourceView = self!.view
                        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                    }
                    guard let topController = UIViewController.topViewController() else {
                        return
                    }
                    topController.present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }
    func data(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    // MARK: - Nib handlers
    private func xibSetup() {
        self.autoresizesSubviews = true
        view = UIView()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizesSubviews = true
        
        contentController.add(self, name: WebViewsKey.callback) //name is the key you want the app to listen to.
        config.userContentController = contentController
        
        addSubview(view)
    }
    
    public func reloadEmbedView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            
            self.view.subviews.forEach({ $0.removeFromSuperview() })
            
            let embedViews = CustomerGlu.entryPointdata.filter {
                $0.mobile.container.type == "EMBEDDED" && $0.mobile.container.bannerId == self.embedId
            }
            
            if embedViews.count != 0 {
                let mobile = embedViews[0].mobile!
                arrContent = [CGContent]()
                condition = mobile.conditions
                
                if mobile.content.count != 0 {
                    for content in mobile.content {
                        arrContent.append(content)
                    }
                    
                    finalHeight = getconfiguredheight()
                    loadAllCampaignsApi()
                    callLoadEmbedAnalytics()
                } else {
                    embedviewHeightchanged(height: 0.0)
                }
            } else {
                embedviewHeightchanged(height: 0.0)
            }
        }
    }
    
    private func embedviewHeightchanged(height : Double) {
        finalHeight = height
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            
            self.constraints.filter{$0.firstAttribute == .height}.forEach({ $0.constant = CGFloat(finalHeight) })
            self.frame.size.height = CGFloat(finalHeight)
            self.view.frame.size.height = CGFloat(finalHeight)
            self.webView.frame.size.height = CGFloat(finalHeight)
            
            let postInfo: [String: Any] = [self.embedId ?? "" : finalHeight]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CGEMBED_FINAL_HEIGHT").rawValue), object: nil, userInfo: postInfo)
            
            invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            
        }
    }
    private func setEmbedView(height: Double, url: String){
        
        let screenWidth = self.frame.size.width
        finalHeight = height
        
        let postInfo: [String: Any] = [self.embedId ?? "" : finalHeight]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CGEMBED_FINAL_HEIGHT").rawValue), object: nil, userInfo: postInfo)
        
        self.constraints.filter{$0.firstAttribute == .height}.forEach({ $0.constant = CGFloat(finalHeight) })
        self.frame.size.height = CGFloat(finalHeight)
        self.view.frame.size.height = CGFloat(finalHeight)
        
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: CGFloat(finalHeight)), configuration: config)
        webView.isUserInteractionEnabled = true
        webView.tag = 0
        webView.load(URLRequest(url: CustomerGlu.getInstance.validateURL(url: URL(string: url)!)))
        self.view.addSubview(webView)
        
        invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    private func loadAllCampaignsApi(){
        
        //        embedviewHeightchanged(height: 0.0)
        ApplicationManager.loadAllCampaignsApi(type: "", value: "", loadByparams: [:]) { [self] success, campaignsModel in
            if success {
//                CustomerGlu.getInstance.loaderHide()
                if arrContent.first?.campaignId.count == 0 {
                    DispatchQueue.main.async { [self] in // Make sure you're on the main thread here
                        self.setEmbedView(height: finalHeight, url: campaignsModel?.defaultUrl ?? "")
                    }
                } else if (arrContent.first?.campaignId.contains("http://"))! || (arrContent.first?.campaignId.contains("https://"))! {
                    DispatchQueue.main.async { [self] in // Make sure you're on the main thread here
                        //self.setupWebViewCustomFrame(url: self.campaign_id)
                        self.setEmbedView(height: finalHeight, url: (arrContent.first?.campaignId)!)
                    }
                } else {
                    let campaigns: [CGCampaigns] = (campaignsModel?.campaigns)!
                    let filteredArray = campaigns.filter{($0.campaignId.elementsEqual((arrContent.first?.campaignId)!)) || ($0.banner != nil && $0.banner?.tag != nil && $0.banner?.tag != "" && ($0.banner!.tag!.elementsEqual((arrContent.first?.campaignId)!)))}
                    if filteredArray.count > 0 {
                        DispatchQueue.main.async {
                            self.setEmbedView(height: self.finalHeight, url: filteredArray[0].url)
                        }
                    } else {
                        DispatchQueue.main.async { [self] in // Make sure you're on the main thread here
                            self.setEmbedView(height: finalHeight, url: campaignsModel?.defaultUrl ?? "")
                        }
                    }
                }
            } else {
//                CustomerGlu.getInstance.loaderHide()
                CustomerGlu.getInstance.printlog(cglog: "Fail to load loadAllCampaignsApi", isException: false, methodName: "CGEmbedView-setEmbedView", posttoserver: true)
            }
        }
        //        invalidateIntrinsicContentSize()
        //        self.layoutIfNeeded()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func getconfiguredheight()->CGFloat {
        var finalheight = 0.0// Default height should be zero (UIScreen.main.bounds.height) * (70/100)
        
        if(arrContent.count > 0){
            let content = arrContent[0]
            let absoluteHeight = content.absoluteHeight ?? 0.0
            let relativeHeight =  content.relativeHeight ?? 0.0
            self.closeOnDeepLink = content.closeOnDeepLink ?? CustomerGlu.auto_close_webview!
            
            if(relativeHeight > 0){
                finalheight = (UIScreen.main.bounds.height) * (relativeHeight/100)
            }else if(absoluteHeight > 0){
                finalheight = absoluteHeight
            }
        }
        
        return finalheight
    }
    
        private func callLoadEmbedAnalytics(){
    
            if (false == loadedapicalled){
                let embedViews = CustomerGlu.entryPointdata.filter {
                    $0.mobile.container.type == "EMBEDDED" && $0.mobile.container.bannerId == self.embedId ?? ""
                }
    
                if embedViews.count != 0 {
                    let mobile = embedViews[0].mobile!
                    arrContent = [CGContent]()
                    condition = mobile.conditions
    
                    if mobile.content.count != 0 {
                        for content in mobile.content {
                            arrContent.append(content)
    
                            CustomerGlu.getInstance.postAnalyticsEventForEntryPoints(event_name: "ENTRY_POINT_LOAD", entry_point_id: content._id, entry_point_name: embedViews[0].name ?? "", entry_point_container: mobile.container.type, content_campaign_id: content.campaignId, open_container:content.openLayout, action_c_campaign_id: content.campaignId)
                        }
                        loadedapicalled = true
                    }
                }
            }
        }
}
