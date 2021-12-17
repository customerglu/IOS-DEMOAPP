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
        var userData = [String: AnyHashable]()
        userData["deviceId"] = "deviceb"
        userData["firebaseToken"] = CustomerGlu.getInstance.fcmToken
        userData["apnsDeviceToken"] = CustomerGlu.getInstance.apnToken
       
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
