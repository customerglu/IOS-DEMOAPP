//
//  File.swift
//
//
//  Created by kapil on 04/11/21.
//

import Foundation
import UIKit

#if !SPM
extension Bundle {
    static var module:Bundle { Bundle(identifier: "org.cocoapods.CustomerGlu") ?? Bundle(for: CustomerGlu.self) }
}
#endif

protocol StoryboardIdentifiable where Self: UIViewController {
   static func getInstance(storyBoardType: StoryboardType) -> UIViewController
}

enum StoryboardType: String {
    
    case main = "Storyboard"
    
    func instance() -> UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: .module)
    }
    
    func instantiate<VC: UIViewController>(vcType: VC.Type) -> VC {
        return (instance().instantiateViewController(withIdentifier: String(describing: vcType.self)) as? VC)!
    }
}
