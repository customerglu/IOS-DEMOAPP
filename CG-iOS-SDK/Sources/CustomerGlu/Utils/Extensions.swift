//
//  File.swift
//  
//
//  Created by kapil on 29/10/21.
//

import Foundation
import UIKit

extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func printJson() {
        print(json)
    }
}

extension String {
    // Replace Space between Strings
    func replace(string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
}

extension UIViewController {
    static func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 2
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropViewShadow() {
        // Update Corners & Shadow
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 3.0
        self.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.22).cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 3.0
    }
}

extension UIImageView {
 
    func downloadImage(urlString: String, success: ((_ image: UIImage?) -> Void)? = nil, failure: ((String) -> Void)? = nil) {
        
        let imageCache = NSCache<NSString, UIImage>()

        DispatchQueue.main.async {[weak self] in
            self?.image = nil
        }
        
        if let image = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {[weak self] in
                self?.image = image
            }
            success?(image)
        } else {
            guard let url = URL(string: urlString) else {
                print("failed to create url")
                return
            }
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) {(data, _, error) in
                
                // response received, now switch back to main queue
                DispatchQueue.main.async {[weak self] in
                    if let error = error {
                        failure?(error.localizedDescription)
                    } else if let data = data, let image = UIImage(data: data) {
                        imageCache.setObject(image, forKey: url.absoluteString as NSString)
                        self?.image = image
                        success?(image)
                    } else {
                        failure?("Image not available")
                    }
                }
            }
            task.resume()
        }
    }
}

extension UIApplication {
    /// The app's key window taking into consideration apps that support multiple scenes.
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }
}
