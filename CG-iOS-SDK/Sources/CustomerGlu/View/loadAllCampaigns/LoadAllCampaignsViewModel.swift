//
//  File.swift
//  
//
//  Created by kapil on 10/11/21.
//

import Foundation
import UIKit

class LoadAllCampaignsViewModel {

    public func updateProfile(completion: @escaping (Bool, RegistrationModel?) -> Void) {
        let fcmRegTokenMessage = UserDefaults.standard.string(forKey: "fcmtoken") ?? "defaultvalue"
        let apnsDeviceTokenMessage = UserDefaults.standard.string(forKey: "apntoken") ?? "defaultvalue"
        var userData = [String: AnyHashable]()
        userData["deviceId"] = "deviceb"
        userData["firebaseToken"] = fcmRegTokenMessage
        userData["apnsDeviceToken"] = apnsDeviceTokenMessage
       
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
