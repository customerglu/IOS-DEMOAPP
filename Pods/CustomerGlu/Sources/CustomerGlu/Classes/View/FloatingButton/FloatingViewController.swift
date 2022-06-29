import UIKit

class FloatingButtonController: UIViewController {
    
    private(set) var imageview: UIImageView!
    private(set) var dismisview: UIView!
    private(set) var dismisimageview: UIImageView!
    var floatInfo: CGData?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(btnInfo: CGData) {
        super.init(nibName: nil, bundle: nil)
        floatInfo = btnInfo
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(note:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    private var window = FloatingButtonWindow()
    
    override func loadView() {
        let view = UIView()
        
        let screenHeight = Int(UIScreen.main.bounds.height)
        let screenWidth = Int(UIScreen.main.bounds.width)
        
        let heightPer = Int((floatInfo?.mobile.container.height)!)!
        let widthPer = Int((floatInfo?.mobile.container.width)!)!
        
        let finalHeight = (screenHeight * heightPer)/100
        let finalWidth = (screenWidth * widthPer)/100
        
        let bottomSpace = (screenHeight * 5)/100
        let sideSpace = (screenWidth * 5)/100
        let topSpace = (screenHeight * 5)/100
        let midX = Int(UIScreen.main.bounds.midX)
        let midY = Int(UIScreen.main.bounds.midY)
        
        let imageview = UIImageView()
        
        if floatInfo?.mobile.container.position == "BOTTOM-LEFT" {
            imageview.frame = CGRect(x: sideSpace, y: screenHeight - (finalHeight + bottomSpace), width: finalWidth, height: finalHeight)
        } else if floatInfo?.mobile.container.position == "BOTTOM-RIGHT" {
            imageview.frame = CGRect(x: screenWidth - (finalWidth + sideSpace), y: screenHeight - (finalHeight + bottomSpace), width: finalWidth, height: finalHeight)
        } else if floatInfo?.mobile.container.position == "BOTTOM-CENTER" {
            imageview.frame = CGRect(x: midX - (finalWidth / 2), y: screenHeight - (finalHeight + bottomSpace), width: finalWidth, height: finalHeight)
        } else if floatInfo?.mobile.container.position == "TOP-LEFT" {
            imageview.frame = CGRect(x: sideSpace, y: topSpace, width: finalWidth, height: finalHeight)
        } else if floatInfo?.mobile.container.position == "TOP-RIGHT" {
            imageview.frame = CGRect(x: screenWidth - (finalWidth + sideSpace), y: topSpace, width: finalWidth, height: finalHeight)
        } else if floatInfo?.mobile.container.position == "TOP-CENTER" {
            imageview.frame = CGRect(x: midX - (finalWidth / 2), y: topSpace, width: finalWidth, height: finalHeight)
        } else if floatInfo?.mobile.container.position == "CENTER-LEFT" {
            imageview.frame = CGRect(x: sideSpace, y: midY - (finalHeight / 2), width: finalWidth, height: finalHeight)
        } else if floatInfo?.mobile.container.position == "CENTER-RIGHT" {
            imageview.frame = CGRect(x: screenWidth - (finalWidth + sideSpace), y: midY - (finalHeight / 2), width: finalWidth, height: finalHeight)
        } else {
            imageview.frame = CGRect(x: midX - (finalWidth / 2), y: midY - (finalHeight / 2), width: finalWidth, height: finalHeight)
        }
        
        imageview.downloadImage(urlString: (floatInfo?.mobile.content[0].url)!)
        imageview.contentMode = .scaleToFill
        imageview.clipsToBounds = true
        imageview.backgroundColor = UIColor.clear
        imageview.layer.shadowColor = UIColor.black.cgColor
        imageview.layer.shadowRadius = 3
        imageview.layer.shadowOpacity = 0.8
        imageview.layer.shadowOffset = CGSize.zero
        imageview.autoresizingMask = []
        imageview.isUserInteractionEnabled = true
        
        if floatInfo?.mobile.container.borderRadius != nil {
            let radius = NumberFormatter().number(from: (floatInfo?.mobile.container.borderRadius)!)
            imageview.layer.cornerRadius = radius as! CGFloat
            imageview.clipsToBounds = true
        }
        
        view.addSubview(imageview)
        self.view = view
        self.imageview = imageview
        window.imageview = imageview
        
        dismisview = UIView(frame: CGRect(x: Int(0.0), y: screenHeight-(screenHeight * 20)/100, width: screenWidth, height: (screenHeight * 20)/100))
        dismisview.backgroundColor = UIColor.clear
        let gradient = CAGradientLayer()
        gradient.frame = dismisview.bounds
        gradient.colors = [UIColor.white.withAlphaComponent(0.9).cgColor,UIColor.black.withAlphaComponent(0.9).cgColor]
        dismisview.layer.insertSublayer(gradient, at: 0)
        dismisview.isHidden = true
        view.addSubview(dismisview)
        
        let lable = UILabel(frame: CGRect(x: 0.0, y: ((dismisview.frame.size.height) / 2), width: dismisview.frame.size.width, height: 20.0))
        lable.text = "Drag here to dismiss"
        lable.textColor = UIColor.white
        lable.textAlignment = .center
        dismisview.addSubview(lable)
        
        dismisimageview = UIImageView(frame: CGRect(x: ((dismisview.frame.size.width) / 2)-25, y: ((dismisview.frame.size.height) / 2)-60, width: 50, height: 50))
        dismisimageview.image = UIImage(named: "imagedismissblack", in: .module, compatibleWith: nil)
        dismisview.addSubview(dismisimageview)
        
        if(floatInfo?.mobile.conditions.draggable == true){
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
            imageview.addGestureRecognizer(panGesture)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        imageview.addGestureRecognizer(tap)
        
        window.imageview?.isHidden = true
        self.imageview.isHidden = true
    }
    
    public func hideFloatingButton(ishidden: Bool) {
        //        window.isHidden = ishidden
        dismisview.isHidden = true
        window.imageview?.isHidden = ishidden
        self.imageview.isHidden = ishidden
        window.isUserInteractionEnabled = !ishidden
        self.imageview.isUserInteractionEnabled = !ishidden
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    public func dismissFloatingButton(is_remove: Bool){
        if CustomerGlu.getInstance.arrFloatingButton.contains(self) {
            
            let finalfloatBtn = CustomerGlu.getInstance.popupDict.filter {
                $0._id == floatInfo?._id
            }
            if is_remove == true {
                CustomerGlu.getInstance.updateShowCount(showCount: finalfloatBtn[0], eventData: floatInfo!)
            }
            if let index = CustomerGlu.getInstance.arrFloatingButton.firstIndex(where: {$0 === self}) {
                CustomerGlu.getInstance.arrFloatingButton.remove(at: index)
                window.dismiss()
            }
        }
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: imageview)
        imageview.center = CGPoint(x: imageview.center.x + translation.x, y: imageview.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: imageview)
        
        if dismisimageview.globalFrame!.intersects(imageview.globalFrame!){
            dismisimageview.image = UIImage(named: "imagedismissred", in: .module, compatibleWith: nil)
        } else {
            dismisimageview.image = UIImage(named: "imagedismissblack", in: .module, compatibleWith: nil)
        }
        
        if(sender.state == .began){
            dismisview.isHidden = false
        } else if (sender.state == .ended) {
            dismisview.isHidden = true
            if dismisimageview.globalFrame!.intersects(imageview.globalFrame!){
                self.dismissFloatingButton(is_remove: true)
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        CustomerGlu.getInstance.callEventPublishNudge(data: floatInfo!, className: CustomerGlu.getInstance.activescreenname, actionType: "OPEN")
        
        if floatInfo?.mobile.content[0].openLayout == "FULL-DEFAULT" {
            CustomerGlu.getInstance.openCampaignById(campaign_id: (floatInfo?.mobile.content[0].campaignId)!, page_type: Constants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: floatInfo?.mobile.conditions.backgroundOpacity ?? 0.5)
        } else if floatInfo?.mobile.content[0].openLayout == "BOTTOM-DEFAULT" {
            CustomerGlu.getInstance.openCampaignById(campaign_id: (floatInfo?.mobile.content[0].campaignId)!, page_type: Constants.BOTTOM_DEFAULT_NOTIFICATION, backgroundAlpha: floatInfo?.mobile.conditions.backgroundOpacity ?? 0.5)
        }  else if floatInfo?.mobile.content[0].openLayout == "BOTTOM-SLIDER" {
            CustomerGlu.getInstance.openCampaignById(campaign_id: (floatInfo?.mobile.content[0].campaignId)!, page_type: Constants.BOTTOM_SHEET_NOTIFICATION, backgroundAlpha: floatInfo?.mobile.conditions.backgroundOpacity ?? 0.5)
        } else {
            CustomerGlu.getInstance.openCampaignById(campaign_id: (floatInfo?.mobile.content[0].campaignId)!, page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: floatInfo?.mobile.conditions.backgroundOpacity ?? 0.5)
        }
    }
    
    @objc func keyboardDidShow(note: NSNotification) {
        window.windowLevel = UIWindow.Level(rawValue: 0)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }
}

private class FloatingButtonWindow: UIWindow {
    
    var imageview: UIImageView?
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            self.windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene)!
        }
        backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let imageview = imageview else {
            return false
            
        }
        let imageviewPoint = convert(point, to: imageview)
        return imageview.point(inside: imageviewPoint, with: event)
    }
}

extension UIView {
    var globalFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        return self.superview?.convert(self.frame, to: rootView)
    }
}

extension UIWindow {
    func dismiss() {
        isHidden = true
        if #available(iOS 13, *) {
            windowScene = nil
        }
    }
}
