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
        imgView.downloadImage(urlString: url)
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
        CustomerGlu.getInstance.presentToCustomerWebViewController(nudge_url: "https://d3guhyj4wa8abr.cloudfront.net/reward/?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJHZmhnaCIsImdsdUlkIjoiYmM5NTUxYTctMjcyZS00NjdlLTlhMGEtM2RiN2Y5NGY3NGFhIiwiY2xpZW50IjoiODRhY2YyYWMtYjJlMC00OTI3LTg2NTMtY2JhMmI4MzgxNmMyIiwiZGV2aWNlSWQiOiIyQzE0OTczQi0wQUQxLTQ4REMtODgwMS1BQkIyNjVFMkU2QkMiLCJkZXZpY2VUeXBlIjoiaW9zIiwiaWF0IjoxNjQ0NDk1MDc5LCJleHAiOjE2NzYwMzEwNzl9.whd0avkTiuNouAZCW36OTTUkoYYEwVDGYS7G0tbTSUw&rewardUserId=319e9c15-16cc-42b8-82db-d3dcd4414108", page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: 0.5)
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        self.bringSubviewToFront(self)
        let translation = sender.translation(in: self)
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self)
    }
}
