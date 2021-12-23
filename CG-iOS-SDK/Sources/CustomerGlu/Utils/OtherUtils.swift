//
//  File.swift
//  
//
//  Created by kapil on 23/12/21.
//

import Foundation
import UIKit

class OtherUtils {
    
    // Singleton Instance
    static let shared = OtherUtils()
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getCrashInfo() -> [String: Any]? {
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let osName = UIDevice.current.systemName
        let udid = UIDevice.current.identifierForVendor?.uuidString
        let timestamp = Date.currentTimeStamp
        let timezone = TimeZone.current.abbreviation()!
        let dict = ["app_name": displayName, "device_name": deviceModel, "os_version": "\(systemName) \(systemVersion)", "app_version": "\(shortVersion)(\(version))", "platform": osName, "device_id": udid!, "timestamp": timestamp, "timezone": timezone] as [String: Any]
        return dict
    }
}
