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
    public static var analyticsUrl = "analytics.customerglu.com/"
    public static var accessToken: String?
    public static var operationQueue = OperationQueue()
    public static var appSessionId = UUID().uuidString
    
    public static func openWalletApi(completion: @escaping (Bool, CampaignsModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        APIManager.getWalletRewards(queryParameters: [:]) { result in
            switch result {
            case .success(let response):
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
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                callCrashReport(stackTrace: error.localizedDescription, methodName: "loadAllCampaigns")
                completion(false, nil)
            }
        }
    }
    
    public static func sendEventData(eventName: String, eventProperties: [String: Any]?, completion: @escaping (Bool, AddCartModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
        let event_id = UUID().uuidString
        let timestamp = fetchTimeStamp(dateFormat: Constants.DATE_FORMAT)
        let user_id = UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_USERID)
        
        let eventData = [
            APIParameterKey.event_id: event_id,
            APIParameterKey.event_name: eventName,
            APIParameterKey.user_id: user_id ?? "",
            APIParameterKey.timestamp: timestamp,
            APIParameterKey.event_properties: eventProperties ?? [String: Any]()] as [String: Any]
        
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
    
    public static func publishNudge(eventNudge: [String: AnyHashable], completion: @escaping (Bool, PublishNudgeModel?) -> Void) {
        if CustomerGlu.sdk_disable! == true {
            print(CustomerGlu.sdk_disable!)
            return
        }
     
        var eventInfo = eventNudge
        eventInfo[APIParameterKey.timestamp] = fetchTimeStamp(dateFormat: Constants.Analitics_DATE_FORMAT)
        
        eventInfo[APIParameterKey.appSessionId] = ApplicationManager.appSessionId
        eventInfo[APIParameterKey.userAgent] = "APP"
        eventInfo[APIParameterKey.deviceType] = "iOS"
        eventInfo[APIParameterKey.eventId] = UUID().uuidString
      eventInfo[APIParameterKey.eventName] = "NUDGE_INTERACTION"
//        eventInfo["actionStore"] = "NUDGE_INTERACTION"
        eventInfo["version"] = "4.0.0"
        
                
        APIManager.publishNudge(queryParameters: eventInfo as NSDictionary) { result in
            switch result {
            case .success(let response):
                completion(true, response)
                    
            case .failure(let error):
                print(error)
                ApplicationManager.callCrashReport(methodName: "publishNudge")
                completion(false, nil)
            }
        }
    }
    
    private static func fetchTimeStamp(dateFormat: String) -> String {
        let date = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormat
        return dateformatter.string(from: date)
    }
}
