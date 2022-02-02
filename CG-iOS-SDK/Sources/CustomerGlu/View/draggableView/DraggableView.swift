//
//  File.swift
//  
//
//  Created by kapil on 02/02/22.
//

import Foundation
import UIKit

enum AlignDirection {
    case center
    case left
    case right
}

public class DraggableView: UIView {
    
    var panGesture = UIPanGestureRecognizer()
    var lblText = UILabel()
    var imgView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.red
        configure()
    }
    
    init(height: Int, width: Int, alignDirection: AlignDirection, url: String) {
                
        switch alignDirection {
        case .center:
            super.init(frame: CGRect(x: Int(UIScreen.main.bounds.midX) - 50, y: Int(UIScreen.main.bounds.height) - (height + 20), width: 100, height: height))
        case .left:
            super.init(frame: CGRect(x: 10, y: Int(UIScreen.main.bounds.height) - (height + 20), width: 100, height: height))
        case .right:
            super.init(frame: CGRect(x: Int(UIScreen.main.bounds.maxX) - 110, y: Int(UIScreen.main.bounds.height) - (height + 20), width: 100, height: height))
        }

        backgroundColor = UIColor.clear
        
        imgView.frame = self.bounds
        let imageExtensions = ["gif"]
        let urlImg: URL? = NSURL(fileURLWithPath: url) as URL
        let pathExtention = urlImg?.pathExtension
        if imageExtensions.contains(pathExtention!) {
            // Do something with it
            let imageURL = UIImage.gifImageWithURL(url)
            imgView = UIImageView(image: imageURL)
        } else {
            imgView.downloadImage(urlString: url)
        }
        imgView.contentMode = .scaleToFill
        imgView.clipsToBounds = true
        self.addSubview(imgView)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.red
        self.backgroundColor = .red
        configure()
    }
    
    private func configure() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(panGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
//        self.removeFromSuperview()
        CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: "https://stackoverflow.com/questions/43714948/draggable-uiview-swift-3", page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: 0.5)
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        self.bringSubviewToFront(self)
        let translation = sender.translation(in: self)
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self)
    }
}
