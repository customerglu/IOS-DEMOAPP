//
//  File.swift
//  
//
//  Created by kapil on 10/11/21.
//

import Foundation

class OpenWalletViewModel {

    public func updateProfile(completion: @escaping (Bool) -> Void) {
        let userData = [String: AnyHashable]()
        CustomerGlu.getInstance.updateProfile(userdata: userData) { success in
            if success {
                completion(true)
            } else {
                completion(false)
                print("error")
            }
        }
    }
}
