//
//  File.swift
//  
//
//  Created by kapil on 10/11/21.
//

import Foundation
import UIKit

class LoadAllCampaignsViewModel {
    
    public func getWalletRewards(completion: @escaping (Bool, CampaignsModel?) -> Void) {
        APIManager.getWalletRewards(queryParameters: [:]) { result in
            switch result {
            case .success(let response):
                completion(true, response)

            case .failure(let error):
                print(error)
                DebugLogger.sharedInstance.setErrorDebugLogger(functionName: "getWalletRewards", exception: error.localizedDescription)
                completion(false, nil)
            }
        }
    }
    
    public func updateProfile(completion: @escaping (Bool, RegistrationModel?) -> Void) {
        let fcmRegTokenMessage = UserDefaults.standard.string(forKey: "fcmtoken") ?? "defaultvalue"
        let userData = [
            "deviceId": "deviceb",
            "firebaseToken": fcmRegTokenMessage
        ]
        
        CustomerGlu.getInstance.updateProfile(userdata: userData) { success, registrationModel in
            if success {
                completion(true, registrationModel)
            } else {
                completion(false, nil)
                print("error")
            }
        }
    }
}
