//
//  File.swift
//  
//
//  Created by kapil on 04/02/22.
//

import Foundation
import UIKit

public class CustomerImageNudgeViewController: UIViewController {
            
    var topSafeArea = UIView()
    var bottomSafeArea = UIView()
    var topHeight = Int()
    var bottomHeight = Int()
    
    var imgView = UIImageView()
    public var urlStr = ""
    var ismiddle = false
    var isbottomsheet = false
    var isbottomdefault = false
    public var alpha = 0.0
    
    public func configureSafeAreaForDevices() {
        let window = UIApplication.shared.keyWindow
        let topPadding = (window?.safeAreaInsets.top)!
        let bottomPadding = (window?.safeAreaInsets.bottom)!

        if topPadding <= 20 || bottomPadding < 20 {
            CustomerGlu.topSafeAreaHeight = 20
            CustomerGlu.bottomSafeAreaHeight = 0
            CustomerGlu.topSafeAreaColor = UIColor.clear
        }

        topHeight = CustomerGlu.topSafeAreaHeight
        bottomHeight = CustomerGlu.bottomSafeAreaHeight
        topSafeArea.backgroundColor = CustomerGlu.topSafeAreaColor
        bottomSafeArea.backgroundColor = CustomerGlu.bottomSafeAreaColor
    }

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        topSafeArea = UIView(frame: CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: topHeight))
        self.view.addSubview(topSafeArea)
        
        bottomSafeArea = UIView(frame: CGRect(x: 0, y: Int(self.view.frame.height - CGFloat(bottomHeight)), width: Int(self.view.frame.width), height: bottomHeight))
        self.view.addSubview(bottomSafeArea)
            
        let x = self.view.frame.midX - 30
        var y = self.view.frame.midY - 30

        self.configureSafeAreaForDevices()
        
        topHeight = 0
        bottomHeight = 0
        let black = UIColor.black
        let blackTrans = UIColor.withAlphaComponent(black)(CGFloat(alpha))
        self.view.backgroundColor = blackTrans
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        let height = (self.view.frame.height) / 1.4
        if ismiddle {
            imgView = UIImageView(frame: CGRect(x: 20, y: (self.view.frame.height - height)/2, width: self.view.frame.width - 40, height: height)) //set your own frame
            imgView.layer.cornerRadius = 20
            imgView.clipsToBounds = true
            y = imgView.frame.midY - 30
        } else if isbottomdefault {
            imgView = UIImageView(frame: CGRect(x: 0, y: self.view.frame.height - height, width: self.view.frame.width, height: height)) //set your own frame
            imgView.layer.cornerRadius = 20
            imgView.clipsToBounds = true
            y = imgView.frame.midY - 30
        } else if isbottomsheet {
            imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.height)) //set your own frame
            y = self.view.frame.midY - 30
        } else {
            topHeight = CustomerGlu.topSafeAreaHeight
            bottomHeight = CustomerGlu.bottomSafeAreaHeight
            imgView = UIImageView(frame: CGRect(x: 0, y: topHeight, width: Int(self.view.frame.width), height: Int(self.view.frame.height) - (topHeight + bottomHeight))) //set your own frame
            y = self.view.frame.midY - 30
        }
        imgView.contentMode = .scaleToFill
        imgView.clipsToBounds = true
        setImageView(url: urlStr, x: x, y: y)
    }
            
    func setImageView(url: String, x: CGFloat, y: CGFloat) {
        if url != "" || !url.isEmpty {
            imgView.downloadImage(urlString: url)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
        self.view.addSubview(imgView)
        CustomerGlu.getInstance.loaderShow(withcoordinate: x, y: y)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: false, completion: nil)
    }
}
