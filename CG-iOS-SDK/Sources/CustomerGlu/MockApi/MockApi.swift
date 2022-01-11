//
//  File.swift
//  
//
//  Created by kapil on 11/01/22.
//

import Foundation

protocol RequestProtocol {
        
    func registerDevice(result: @escaping (Bool, RegistrationModel?) -> Void)
    
    func loadAllCampaigns(result: @escaping (Bool, CampaignsModel?) -> Void)
    
    func addCart(result: @escaping (Bool, AddCartModel?) -> Void)
}

class MockApi: RequestProtocol {
   
    // Singleton Instance
    static let shared = MockApi()
    
    func registerDevice(result: @escaping (Bool, RegistrationModel?) -> Void) {
        let data = MockData.loginResponse.data(using: .utf8)!
        do {
            let registrationResponse = try JSONDecoder().decode(RegistrationModel.self, from: data)
            result(true, registrationResponse)
        } catch {
            print(error)
            result(false, nil)
        }
    }
    
    func loadAllCampaigns(result: @escaping (Bool, CampaignsModel?) -> Void) {
        let data = MockData.walletResponse.data(using: .utf8)!
        do {
            let campaignResponse = try JSONDecoder().decode(CampaignsModel.self, from: data)
            result(true, campaignResponse)
        } catch {
            print(error)
            result(false, nil)
        }
    }
   
    func addCart(result: @escaping (Bool, AddCartModel?) -> Void) {
        let data = MockData.addcartResponse.data(using: .utf8)!
        do {
            let addCartResponse = try JSONDecoder().decode(AddCartModel.self, from: data)
            result(true, addCartResponse)
        } catch {
            print(error)
            result(false, nil)
        }
    }
}
