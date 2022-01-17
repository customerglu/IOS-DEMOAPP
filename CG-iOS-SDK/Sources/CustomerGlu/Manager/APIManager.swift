//
//  File.swift
//  
//
//  Created by hitesh on 28/10/21.
//

import Foundation
import UIKit
import SwiftUI

// HTTP Header Field's for API's
private enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case xapikey = "x-api-key"
}

// HTTP Header Value's for API's
private enum ContentType: String {
    case json = "application/json"
}

// MARK: - ProfileEndPoint Model
internal class MethodandPath: Codable {
    
    // MARK: - Variables
    internal var method: String
    internal var path: String
    
    init(method: String?, path: String?) {
        self.method = method!
        self.path = path!
    }
}

// Parameter Key's for all API's
private struct MethodNameandPath {
    static let userRegister = MethodandPath(method: "POST", path: "user/v1/user/sdk?token=true")
    static let getWalletRewards = MethodandPath(method: "GET", path: "reward/v1.1/user")
    static let addToCart = MethodandPath(method: "POST", path: "v3/server")
    static let crashReport = MethodandPath(method: "PUT", path: "api/v1/report")
}

// Parameter Key's for all API's
private struct BaseUrls {
    static let baseurl = ApplicationManager.baseUrl
    static let streamurl = ApplicationManager.streamUrl
}

// Class contain Helper Methods Used in Overall Application Related to API Calls
class APIManager {
    
    // Singleton Instance
    static let shared = APIManager()
    
    private static func performRequest<T: Decodable>(baseurl: String, methodandpath: MethodandPath, parametersDict: NSDictionary?, completion: @escaping (Result<T, Error>) -> Void) {

        var urlRequest: URLRequest!
        var url: URL!
        let strUrl = "https://" + baseurl
        url = URL(string: strUrl + methodandpath.path)!
        urlRequest = URLRequest(url: url)
        print(urlRequest!)
        
        // HTTP Method
        urlRequest.httpMethod = methodandpath.method//method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        if UserDefaults.standard.object(forKey: Constants.CUSTOMERGLU_TOKEN) != nil {
            urlRequest.setValue("\(APIParameterKey.bearer) " + UserDefaults.standard.string(forKey: Constants.CUSTOMERGLU_TOKEN)!, forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
            urlRequest.setValue(Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String, forHTTPHeaderField: HTTPHeaderField.xapikey.rawValue)
        }
       
        if parametersDict!.count > 0 { // Check Parameters & Move Accordingly
            print(parametersDict as Any)
            if methodandpath.method == "GET" {
                var urlString = ""
                for (i, (keys, values)) in parametersDict!.enumerated() {
                    urlString += i == 0 ? "?\(keys)=\(values)" : "&\(keys)=\(values)"
                }
                // Append GET Parameters to URL
                var absoluteStr = url.absoluteString
                absoluteStr += urlString
                absoluteStr = absoluteStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                urlRequest.url = URL(string: absoluteStr)!
            } else {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parametersDict as Any, options: .fragmentsAllowed)
            }
        }
        
        // Mock Env for Unit Testing
        let enviroment = ProcessInfo.processInfo.environment["ENV"]
        if enviroment == "TEST" {
            var data = Data()
            if T.self == RegistrationModel.self {
                data = MockData.loginResponse.data(using: .utf8)!
            } else if T.self == CampaignsModel.self {
                data = MockData.walletResponse.data(using: .utf8)!
            } else if T.self == AddCartModel.self {
                data = MockData.addcartResponse.data(using: .utf8)!
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                // Get JSON, Clean it and Convert to Object
                let JSON = json
                JSON?.printJson()
                let cleanedJSON = cleanJSON(json: JSON!, isReturn: true)
                dictToObject(dict: cleanedJSON, type: T.self, completion: completion)
            } catch let error as NSError {
                print(error)
            }
            
        } else {
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 401 {
                        resetDefaults()
                        return
                    }
                }
                guard let data = data, error == nil else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                    // Get JSON, Clean it and Convert to Object
                    let JSON = json
                    JSON?.printJson()
                    let cleanedJSON = cleanJSON(json: JSON!, isReturn: true)
                    dictToObject(dict: cleanedJSON, type: T.self, completion: completion)
                } catch let error as NSError {
                    print(error)
                }
            }.resume()
        }
    }
    
    static func userRegister(queryParameters: NSDictionary, completion: @escaping (Result<RegistrationModel, Error>) -> Void) {
        // Call Login API with API Router
        performRequest(baseurl: BaseUrls.baseurl, methodandpath: MethodNameandPath.userRegister, parametersDict: queryParameters, completion: completion)
    }
    
    static func getWalletRewards(queryParameters: NSDictionary, completion: @escaping (Result<CampaignsModel, Error>) -> Void) {
        // Call Get Wallet and Rewards List
        performRequest(baseurl: BaseUrls.baseurl, methodandpath: MethodNameandPath.getWalletRewards, parametersDict: queryParameters, completion: completion)
    }
    
    static func addToCart(queryParameters: NSDictionary, completion: @escaping (Result<AddCartModel, Error>) -> Void) {
        // Call Get Wallet and Rewards List
        performRequest(baseurl: BaseUrls.streamurl, methodandpath: MethodNameandPath.addToCart, parametersDict: queryParameters, completion: completion)
    }
    
    static func crashReport(queryParameters: NSDictionary, completion: @escaping (Result<AddCartModel, Error>) -> Void) {
        // Call Get Wallet and Rewards List
        performRequest(baseurl: BaseUrls.baseurl, methodandpath: MethodNameandPath.crashReport, parametersDict: queryParameters, completion: completion)
    }
    
    // MARK: - Private Class Methods
    
    // Recursive Method
    @discardableResult
    static private func cleanJSON(json: Dictionary<String, Any>, isReturn: Bool = false) -> Dictionary<String, Any> {
        
        // Create Local Object to Mutate
        var actualJson = json
        
        // Iterate Over All Pairs
        for (key, value) in actualJson {
            
            if let dict = value as? Dictionary<String, Any> { // If Value is Dictionary then call itself with new value
                cleanJSON(json: dict)
            } else if let array = value as? [Dictionary<String, Any>] {
                
                // If Value is Array then call itself according to number of elements
                for element in array {
                    cleanJSON(json: element)
                }
            }
            
            // If value if not null then move inside
            if !(value is NSNull) {
                
                // If value is "_null" String then remove it
                if let text = value as? String, text == "_null" {
                    actualJson.removeValue(forKey: key)
                }
            } else {
                
                // remove null value
                actualJson.removeValue(forKey: key)
            }
        }
        
        // If called with isReturn as true then only return actual object
        if isReturn {
            return actualJson
        } else { // else return dummy object
            return Dictionary<String, Any>()
        }
    }
    
    static private func dictToObject <T: Decodable>(dict: Dictionary<String, Any>, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        do {
            // Convert Dictionary to JSON Data
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            
            // Decode data to model object
            let jsonDecoder = JSONDecoder()
            let object = try jsonDecoder.decode(type, from: jsonData)
            
            // response with model object
            completion(.success(object))
        } catch let error { // response with error
            completion(.failure(error))
        }
    }
    
    static private func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
