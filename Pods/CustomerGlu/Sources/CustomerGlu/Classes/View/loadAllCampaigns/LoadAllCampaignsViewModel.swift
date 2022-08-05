//
//  File.swift
//  
//
//  Created by kapil on 10/11/21.
//

import Foundation

class LoadAllCampaignsViewModel {

    public func updateProfile(completion: @escaping (Bool) -> Void) {
        let userData = [String: AnyHashable]()
        CustomerGlu.getInstance.updateProfile(userdata: userData) { success in
            if success {
                completion(true)
            } else {
                completion(false)
                CustomerGlu.getInstance.printlog(cglog: "UpdateProfile API fail", isException: false, methodName: "LoadAllCampaignsViewModel-updateProfile", posttoserver: true)
            }
        }
    }
}
