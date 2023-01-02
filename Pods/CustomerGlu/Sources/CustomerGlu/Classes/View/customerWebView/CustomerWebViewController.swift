//
//  File.swift
//
//
//  Created by kapil on 09/11/21.
//

import Foundation
import UIKit
import WebKit

public class CustomerWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    public static let storyboardVC = StoryboardType.main.instantiate(vcType: CustomerWebViewController.self)
    
    @IBOutlet weak var topSafeArea: UIView!
    @IBOutlet weak var bottomSafeArea: UIView!
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var webView = WKWebView()
    var coverview = UIView()
    public var urlStr = ""
    private var loadedurl = ""
    private var defaultwalleturl = ""
    public var auto_close_webview = CustomerGlu.auto_close_webview
    var notificationHandler = false
    var ismiddle = false
    var isbottomsheet = false
    var isbottomdefault = false
    var iscampignId = false
    var documentInteractionController: UIDocumentInteractionController!
    public var alpha = 0.0
    var campaign_id = ""
    private var dismissactionglobal = CGDismissAction.UI_BUTTON
    
    let contentController = WKUserContentController()
    let config = WKWebViewConfiguration()
    
    var postdata = [String:Any]()
    var canpost = false
    var canopencgwebview = false
    public var nudgeConfiguration: CGNudgeConfiguration?
    private var opencgwebview_nudgeConfiguration: CGNudgeConfiguration?
    private var defaulttimer : Timer?
    
    public func configureSafeAreaForDevices() {
        let window = UIApplication.shared.keyWindow
        let topPadding = (window?.safeAreaInsets.top)!
        let bottomPadding = (window?.safeAreaInsets.bottom)!
        
        if topPadding <= 20 || bottomPadding < 20 {
            CustomerGlu.topSafeAreaHeight = 20
            CustomerGlu.bottomSafeAreaHeight = 0
//            CustomerGlu.topSafeAreaColor = UIColor.clear
        }
        
        topHeight.constant = CGFloat(CustomerGlu.topSafeAreaHeight)
        bottomHeight.constant = CGFloat(CustomerGlu.bottomSafeAreaHeight)
        topSafeArea.backgroundColor = CustomerGlu.topSafeAreaColor
        bottomSafeArea.backgroundColor = CustomerGlu.bottomSafeAreaColor
    }
    public override var shouldAutorotate: Bool{
        return false;
    }
    
    func getframe()->CGRect{
        var rect = CGRect.zero
        
        let height = getconfiguredheight()
        if ismiddle {
            rect = CGRect(x: 20, y: (self.view.frame.height - height)/2, width: self.view.frame.width - 40, height: height)
            
        } else if isbottomdefault {
            rect = CGRect(x: 0, y: self.view.frame.height - height, width: self.view.frame.width, height: height)
        } else if isbottomsheet {
            rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.height)
        } else {
            topHeight.constant = CGFloat(CustomerGlu.topSafeAreaHeight)
            bottomHeight.constant = CGFloat(CustomerGlu.bottomSafeAreaHeight)
            rect = CGRect(x: 0, y: topHeight.constant, width: self.view.frame.width, height: self.view.frame.height - (topHeight.constant + bottomHeight.constant))
        }
        
        return rect
    }
    @objc func rotated() {
        for subview in self.view.subviews {
            if(subview == webView){
                
                let height = getconfiguredheight()
                webView.frame = getframe()
                coverview.frame = webView.frame
            }
        }
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if(self.nudgeConfiguration != nil){
            self.alpha = nudgeConfiguration!.opacity
            self.auto_close_webview = nudgeConfiguration!.closeOnDeepLink
            
            if(nudgeConfiguration!.layout == CGConstants.MIDDLE_NOTIFICATIONS || nudgeConfiguration!.layout == CGConstants.MIDDLE_NOTIFICATIONS_POPUP){
                self.ismiddle = true
            }else if(nudgeConfiguration!.layout == CGConstants.BOTTOM_DEFAULT_NOTIFICATION || nudgeConfiguration!.layout == CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP){
                self.isbottomdefault = true
            }else if(nudgeConfiguration!.layout == CGConstants.BOTTOM_SHEET_NOTIFICATION){
                self.isbottomsheet = true
            }
            
        }
        
        contentController.add(self, name: WebViewsKey.callback) //name is the key you want the app to listen to.
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true
        
        topHeight.constant = CGFloat(0.0)
        bottomHeight.constant = CGFloat(0.0)
        let black = UIColor.black
        let blackTrans = UIColor.withAlphaComponent(black)(CGFloat(alpha))
        self.view.backgroundColor = blackTrans
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        let x = self.view.frame.midX - 30
        let y = self.view.frame.midY - 30
        
        self.configureSafeAreaForDevices()
        
        if notificationHandler {
            setupWebViewCustomFrame(url: urlStr)
        } else if iscampignId {
            
            CustomerGlu.getInstance.loaderShow(withcoordinate: getframe().midX, y: getframe().midY)
            
            campaign_id = campaign_id.trimSpace()
            
            ApplicationManager.loadAllCampaignsApi(type: "", value: campaign_id, loadByparams: [:]) { success, campaignsModel in
                if success {
                    CustomerGlu.getInstance.loaderHide()
                    self.defaultwalleturl = String(campaignsModel?.defaultUrl ?? "")
                    if self.campaign_id.count == 0 {
                        DispatchQueue.main.async { [self] in // Make sure you're on the main thread here
                            self.setupWebViewCustomFrame(url: campaignsModel?.defaultUrl ?? "")
                        }
                    } else if self.campaign_id.contains("http://") || self.campaign_id.contains("https://") {
                        DispatchQueue.main.async { [self] in // Make sure you're on the main thread here
                            self.setupWebViewCustomFrame(url: self.campaign_id)
                        }
                    } else {
                        let campaigns: [CGCampaigns] = (campaignsModel?.campaigns)!
                        let filteredArray = campaigns.filter{($0.campaignId.elementsEqual(self.campaign_id)) || ($0.banner != nil && $0.banner?.tag != nil && $0.banner?.tag != "" && ($0.banner!.tag!.elementsEqual(self.campaign_id)))}
                        if filteredArray.count > 0 {
                            DispatchQueue.main.async {
                                self.setupWebViewCustomFrame(url: filteredArray[0].url)
                            }
                        } else {
                            DispatchQueue.main.async { [self] in // Make sure you're on the main thread here
                                self.setupWebViewCustomFrame(url: campaignsModel?.defaultUrl ?? "")
                            }
                        }
                    }
                } else {
                    CustomerGlu.getInstance.loaderHide()
                    CustomerGlu.getInstance.printlog(cglog: "Fail to load loadAllCampaignsApi", isException: false, methodName: "CustomerWebViewController-viewDidLoad", posttoserver: true)
                }
            }
        } else {
            webView = WKWebView(frame: getframe(), configuration: config) //set your own frame
            loadwebView(url: urlStr, x: x, y: y)
        }
        webView.scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    private func setupWebViewCustomFrame(url: String) {
        
        let x = self.view.frame.midX - 30
        var y = self.view.frame.midY - 30
        
        let height = getconfiguredheight()
        if ismiddle {
            webView = WKWebView(frame: getframe(), configuration: config) //set your own frame
            webView.layer.cornerRadius = 20
            webView.clipsToBounds = true
            y = webView.frame.midY - 30
        } else if isbottomdefault {
            webView = WKWebView(frame: getframe(), configuration: config) //set your own frame
            webView.layer.cornerRadius = 20
            webView.clipsToBounds = true
            y = webView.frame.midY - 30
        } else if isbottomsheet {
            webView = WKWebView(frame: getframe(), configuration: config) //set your own frame
            y = self.view.frame.midY - 30
        } else {
            topHeight.constant = CGFloat(CustomerGlu.topSafeAreaHeight)
            bottomHeight.constant = CGFloat(CustomerGlu.bottomSafeAreaHeight)
            webView = WKWebView(frame: getframe(), configuration: config) //set your own frame
            y = self.view.frame.midY - 30
        }
        loadwebView(url: url, x: x, y: y)
    }
    private func getconfiguredheight()->CGFloat {
        var finalheight = (self.view.frame.height) * (70/100)
        
        if(nudgeConfiguration != nil){
            if(nudgeConfiguration!.relativeHeight > 0){
                finalheight = (self.view.frame.height) * (nudgeConfiguration!.relativeHeight/100)
            }else if(nudgeConfiguration!.absoluteHeight > 0){
                finalheight = nudgeConfiguration!.absoluteHeight
            }
        }
        
        if (finalheight > (UIScreen.main.bounds.height - (topHeight.constant + bottomHeight.constant))){
            finalheight = (UIScreen.main.bounds.height - (topHeight.constant + bottomHeight.constant))
        }
        
        return finalheight
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if (!(ismiddle || isbottomdefault || isbottomsheet)){
            self.view.backgroundColor = CustomerGlu.getInstance.checkIsDarkMode() ? CustomerGlu.darkBackground: CustomerGlu.lightBackground
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isbottomsheet {
            CustomerGlu.getInstance.setCurrentClassName(className: CustomerGlu.getInstance.activescreenname)
        }
        if (true == self.canpost){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: self.postdata)
            self.canpost = false
            self.postdata = [String:Any]()
        }
        if (true == self.canopencgwebview){
            self.canopencgwebview = false
            self.openCGWebView()
        }
    }
    
    func loadwebView(url: String, x: CGFloat, y: CGFloat) {
        webView.navigationDelegate = self
        if url != "" || !url.isEmpty {
            self.loadedurl = url
            if ((campaign_id != CGConstants.CGOPENWALLET) && (loadedurl != nil && loadedurl.count > 0 && loadedurl == defaultwalleturl)){
                var eventInfo = [String: Any]()
                eventInfo["campaignId"] = campaign_id
                eventInfo[APIParameterKey.messagekey] = "Invalid campaignId, opening Wallet"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CG_INVALID_CAMPAIGN_ID").rawValue), object: nil, userInfo: eventInfo as? [String: Any])
            }
            webView.backgroundColor = CustomerGlu.getInstance.checkIsDarkMode() ? CustomerGlu.darkBackground: CustomerGlu.lightBackground
            let darkUrl = url + "&darkMode=" + (CustomerGlu.getInstance.checkIsDarkMode() ? "true" : "false")
            print("This is the URL ------- "+darkUrl)
            webView.load(URLRequest(url: CustomerGlu.getInstance.validateURL(url: URL(string: darkUrl)!)))
            webView.isHidden = true
            
            coverview.frame = webView.frame
            coverview.isHidden = !webView.isHidden
            coverview.backgroundColor = webView.backgroundColor

            self.view.addSubview(webView)
            self.view.addSubview(coverview)
            CustomerGlu.getInstance.loaderShow(withcoordinate: getframe().midX, y: getframe().midY)
            defaulttimer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(timeoutforpageload(sender:)), userInfo: nil, repeats: false)
        } else {
            self.closePage(animated: false,dismissaction: CGDismissAction.UI_BUTTON)
        }
    }
    
    @objc private  func timeoutforpageload(sender: Timer) {
        hideLoaderNShowWebview()
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.closePage(animated: false,dismissaction: CGDismissAction.UI_BUTTON)
    }
    
    private func closePage(animated: Bool,dismissaction:String){
        self.dismissactionglobal = dismissaction
        self.dismiss(animated: animated) {
            CustomerGlu.getInstance.showFloatingButtons()
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        postAnalyticsEventForWebView(isopenevent: true, dismissaction: CGDismissAction.UI_BUTTON)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "didFailProvisionalNavigation", posttoserver: true)
        
        hideLoaderNShowWebview()
    }
    
    // receive message from wkwebview
    public func userContentController(
        _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
        
        if message.name == WebViewsKey.callback {
            guard let bodyString = message.body as? String,
                  let bodyData = bodyString.data(using: .utf8) else { fatalError() }
            
            let bodyStruct = try? JSONDecoder().decode(CGEventModel.self, from: bodyData)
            
            print("bodyStruct?.eventName -- \(bodyStruct?.eventName)")
            if bodyStruct?.eventName == WebViewsKey.close {
                if notificationHandler || iscampignId {
                    self.closePage(animated: true,dismissaction: CGDismissAction.UI_BUTTON)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            if bodyStruct?.eventName == WebViewsKey.open_deeplink {
                let deeplink = try? JSONDecoder().decode(CGDeepLinkModel.self, from: bodyData)
                if  let deep_link = deeplink?.data?.deepLink {
                    print("link", deep_link)
                    postdata = OtherUtils.shared.convertToDictionary(text: (message.body as? String)!) ?? [String:Any]()
                    self.canpost = true
                    if self.auto_close_webview == true {
                        // Posted a notification in viewDidDisappear method
                        if notificationHandler || iscampignId {
                            self.closePage(animated: true,dismissaction: CGDismissAction.CTA_REDIRECT)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else{
                        // Post notification
                        self.canpost = false
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: self.postdata)
                        self.postdata = [String:Any]()
                    }
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
            
            if bodyStruct?.eventName == WebViewsKey.hideloader {
                hideLoaderNShowWebview()
            }
            
            if bodyStruct?.eventName == WebViewsKey.opencgwebview {
                    let dict = OtherUtils.shared.convertToDictionary(text: (message.body as? String)!)
                    if(dict != nil && dict!.count>0 && dict?["data"] != nil){
                        
                        let datadic = dict?["data"] as? [String : Any]
                        
                        var contenttype = "WALLET"
                        var contenturl = ""
                        var contentcampaignId = ""
                        var containertype = CGConstants.FULL_SCREEN_NOTIFICATION
                        var containerabsoluteHeight = 0.0
                        var containerrelativeHeight = 0.0
                        var hidePrevious = false
                        
                        if(datadic != nil && datadic!.count>0 && datadic!["content"] != nil){
                            
                            let contentdic = datadic!["content"] as? [String : Any]
                            if(contentdic != nil && contentdic!.count > 0){
                                
                                 contenttype = contentdic!["type"] as? String ?? "WALLET"
                                 contenturl = contentdic!["url"] as? String ?? ""
                                 contentcampaignId = contentdic!["campaignId"] as? String ?? ""
                            }

                        }
                        if(datadic != nil && datadic!.count>0 && datadic!["container"] != nil){
                            
                            let containerdic = datadic!["container"] as? [String : Any]
                            
                             containertype = containerdic!["type"] as? String ?? CGConstants.FULL_SCREEN_NOTIFICATION
                             containerabsoluteHeight = containerdic!["absoluteHeight"] as? Double ?? 0.0
                             containerrelativeHeight = containerdic!["relativeHeight"] as? Double ?? 0.0
                            
                        }
                        if(datadic != nil && datadic!.count>0 && datadic!["hidePrevious"] != nil){
                            
                            hidePrevious = datadic!["hidePrevious"] as? Bool ?? false

                        }
                        
                        opencgwebview_nudgeConfiguration = CGNudgeConfiguration()
                        opencgwebview_nudgeConfiguration?.absoluteHeight = containerabsoluteHeight
                        opencgwebview_nudgeConfiguration?.relativeHeight = containerrelativeHeight
                        opencgwebview_nudgeConfiguration?.layout = containertype
                        if(contenttype == "CAMPAIGN"){
                            opencgwebview_nudgeConfiguration?.url = contentcampaignId
                        }else if(contenttype == "WALLET"){
                            opencgwebview_nudgeConfiguration?.url = CGConstants.CGOPENWALLET
                        }else{
                            opencgwebview_nudgeConfiguration?.url = contenturl
                        }
                        
                        if(true == hidePrevious){
                            canopencgwebview = true
                            if notificationHandler || iscampignId {
                                self.closePage(animated: true,dismissaction: CGDismissAction.CTA_REDIRECT)
                            }else{
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else{
                            canopencgwebview = false
                            openCGWebView()
                        }
                        
                    }
            }

        }
    }
    private func openCGWebView(){
        if(opencgwebview_nudgeConfiguration != nil){
            
            if(CGConstants.CGOPENWALLET == opencgwebview_nudgeConfiguration?.url){
                CustomerGlu.getInstance.loadCampaignById(campaign_id: CGConstants.CGOPENWALLET, nudgeConfiguration: opencgwebview_nudgeConfiguration)
            }else{
                CustomerGlu.getInstance.loadCampaignById(campaign_id: opencgwebview_nudgeConfiguration?.url ?? "", nudgeConfiguration: opencgwebview_nudgeConfiguration)
            }

        }
    }
    private func hideLoaderNShowWebview(){
        
        if(defaulttimer != nil){
            defaulttimer?.invalidate()
            defaulttimer = nil
        }
        
        CustomerGlu.getInstance.loaderHide()
        webView.isHidden = false
        coverview.isHidden = !webView.isHidden
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
        self.present(activityViewController, animated: true, completion: nil)
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
                    self!.present(activityViewController, animated: true, completion: nil)
                }
            }
        }
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
    
    func data(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    private func postAnalyticsEventForWebView(isopenevent:Bool,dismissaction:String) {
        if (false == CustomerGlu.analyticsEvent) {
            return
        }
        var eventInfo = [String: Any]()
        
        if(isopenevent){
            eventInfo[APIParameterKey.event_name] = "WEBVIEW_LOAD"
        }else{
            eventInfo[APIParameterKey.event_name] = "WEBVIEW_DISMISS"
            eventInfo[APIParameterKey.dismiss_trigger] = dismissaction
        }

        var webview_content = [String: String]()
        webview_content[APIParameterKey.webview_url] = loadedurl
        
        var webview_layout = ""
        var absolute_height = String(0.0)
        var relative_height = String(70.0)
        if(nudgeConfiguration != nil){
            webview_layout = nudgeConfiguration!.layout
            if(nudgeConfiguration!.absoluteHeight > 0 && nudgeConfiguration!.relativeHeight > 0){
                absolute_height = String(nudgeConfiguration!.absoluteHeight)
                relative_height = String(nudgeConfiguration!.relativeHeight)
            }else if(nudgeConfiguration!.relativeHeight > 0){
                relative_height = String(nudgeConfiguration!.relativeHeight)
            }else if(nudgeConfiguration!.absoluteHeight > 0){
                absolute_height = String(nudgeConfiguration!.absoluteHeight)
                relative_height = String(0.0)
            }
            
            if(nudgeConfiguration!.layout == CGConstants.FULL_SCREEN_NOTIFICATION || nudgeConfiguration!.relativeHeight > 100){
                relative_height = String(100.0)
            }
            
        }else{
            if ismiddle {
                webview_layout = CGConstants.MIDDLE_NOTIFICATIONS_POPUP
            } else if isbottomdefault {
                webview_layout = CGConstants.BOTTOM_DEFAULT_NOTIFICATION_POPUP
            } else if isbottomsheet {
                webview_layout = CGConstants.BOTTOM_SHEET_NOTIFICATION
            } else {
                webview_layout = CGConstants.FULL_SCREEN_NOTIFICATION
                relative_height = String(100.0)
            }
        }
        webview_content[APIParameterKey.webview_layout] = webview_layout
        webview_content[APIParameterKey.absolute_height] = absolute_height
        webview_content[APIParameterKey.relative_height] = relative_height
        eventInfo[APIParameterKey.webview_content] = webview_content
             
        ApplicationManager.sendAnalyticsEvent(eventNudge: eventInfo) { success, _ in
            if success {
                print(success)
            } else {
                CustomerGlu.getInstance.printlog(cglog: "Fail to call sendAnalyticsEvent", isException: false, methodName: "WebView-postAnalyticsEventForWebView", posttoserver: true)
            }
        }
        

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_ANALYTICS_EVENT").rawValue), object: nil, userInfo: eventInfo as? [String: Any])

    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            // TODO: Do your stuff here.
            postAnalyticsEventForWebView(isopenevent: false, dismissaction: dismissactionglobal)
        }
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        checkIsDarkMode()
    }
    
}
