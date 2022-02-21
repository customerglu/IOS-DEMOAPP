//
//  File.swift
//  
//
//  Created by hitesh on 28/10/21.
//

import Foundation

class ApplicationManager {
    public static var baseUrl = "api.customerglu.com/"
    public static var streamUrl = "stream.customerglu.com/"
    public static var accessToken: String?
    
    public static func openWalletApi(completion: @escaping (Bool, CampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        APIManager.getWalletRewards(queryParameters: [:]) { result in
            switch result {
            case .success(let response):
                var campaigndata = CampaignsModel()
                campaigndata = response
                do {
                    try UserDefaults.standard.setObject(campaigndata, forKey: Constants.WalletRewardData)
                } catch {
                    print(error.localizedDescription)
                }
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                callCrashReport(stackTrace: error.localizedDescription, methodName: "openWallet")
                completion(false, nil)
            }
        }
    }
    
    public static func loadAllCampaignsApi(type: String, value: String, loadByparams: NSDictionary, completion: @escaping (Bool, CampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        
        var params = [String: AnyHashable]()
        
        if loadByparams.count != 0 {
            params = (loadByparams as? [String: AnyHashable])!
        } else {
            if type != "" {
                params[type] = value
            }
        }
        
        APIManager.getWalletRewards(queryParameters: params as NSDictionary) { result in
            switch result {
            case .success(let response):
                
                var campaigndata = CampaignsModel()
                campaigndata = response
                do {
                    try UserDefaults.standard.setObject(campaigndata, forKey: Constants.WalletRewardData)
                } catch {
                    print(error.localizedDescription)
                }
                
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                callCrashReport(stackTrace: error.localizedDescription, methodName: "loadAllCampaigns")
                completion(false, nil)
            }
        }
    }
    
    public static func sendEventData(eventName: String, eventProperties: [String: Any], completion: @escaping (Bool, AddCartModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        let date = Date()
        let event_id = UUID().uuidString
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = Constants.DATE_FORMAT
        let timestamp = dateformatter.string(from: date)
        let user_id = UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)
        
        let eventData = [
            APIParameterKey.event_id: event_id,
            APIParameterKey.event_name: eventName,
            APIParameterKey.user_id: user_id ?? "",
            APIParameterKey.timestamp: timestamp,
            APIParameterKey.event_properties: eventProperties] as [String: Any]
        
        APIManager.addToCart(queryParameters: eventData as NSDictionary) { result in
            switch result {
            case .success(let response):
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                callCrashReport(stackTrace: error.localizedDescription, methodName: "addToCart")
                completion(false, nil)
            }
        }
    }
    
    public static func callCrashReport(stackTrace: String = "", isException: Bool = false, methodName: String = "") {
        let user_id = UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)
        if user_id == nil && user_id?.count ?? 0 < 0 {
            return
        }
        var params = OtherUtils.shared.getCrashInfo()
        if isException {
            params![APIParameterKey.type] = "Crash"
        } else {
            params![APIParameterKey.type] = "Error"
        }
        params![APIParameterKey.stack_trace] = stackTrace
        params![APIParameterKey.method] = methodName
        params![APIParameterKey.user_id] = user_id
        params![APIParameterKey.version] = "1.0.0"
        crashReport(parameters: (params as NSDictionary?)!) { success, _ in
            if success {
                UserDefaults.standard.removeObject(forKey: Constants.CustomerGluCrash)
                UserDefaults.standard.synchronize()
            } else {
                print("error")
            }
        }
    }
    
    private static func crashReport(parameters: NSDictionary, completion: @escaping (Bool, AddCartModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        APIManager.crashReport(queryParameters: parameters) { result in
            switch result {
            case .success(let response):
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                ApplicationManager.callCrashReport(stackTrace: error.localizedDescription, methodName: "crashReport")
                completion(false, nil)
            }
        }
    }
    
    public static func doValidateToken() -> Bool {
        if UserDefaults.standard.object(forKey: Constants.CUSTOMERGLU_TOKEN) != nil {
            let arr = JWTDecode.shared.decode(jwtToken: UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN) ?? "")
            let expTime = Date(timeIntervalSince1970: (arr["exp"] as? Double)!)
            let currentDateTime = Date()
            if currentDateTime < expTime {
                return true
            } else {
                return false
            }
        }
        return false
    }
}
