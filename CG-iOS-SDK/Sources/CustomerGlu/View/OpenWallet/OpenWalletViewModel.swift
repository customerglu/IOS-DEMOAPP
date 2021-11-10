//
//  File.swift
//  
//
//  Created by kapil on 10/11/21.
//

import Foundation
import UIKit

class OpenWalletViewModel {
    
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
}
