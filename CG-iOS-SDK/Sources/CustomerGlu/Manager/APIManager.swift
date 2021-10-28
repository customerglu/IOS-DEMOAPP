//
//  File.swift
//  
//
//  Created by hitesh on 28/10/21.
//

import Foundation
import UIKit

// Parameter Key's for all API's
private struct APIParameterKey {
    static let password = "password"
    static let email = "email"
    static let client = "client"
    static let version = "version"
    static let oldPassword = "oldPassword"
    static let providerName = "providerName"
}

// HTTP Header Field's for API's
private enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
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
}

// Class contain Helper Methods Used in Overall Application Related to API Calls
class APIManager {
    
    // Singleton Instance
    static let shared = APIManager()
    
    private static func performRequest<T: Decodable>(methodandpath: MethodandPath, parametersDict: NSDictionary?, completion: @escaping (Result<T, Error>) -> Void) {
        
        var urlRequest: URLRequest!
        var url: URL!
        
        let strUrl = "https://" + ApplicationManager.baseUrl
        url = URL(string: strUrl + methodandpath.path)!
        urlRequest = URLRequest(url: url)
        print(urlRequest!)
        
        // HTTP Method
        urlRequest.httpMethod = methodandpath.method//method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        if parametersDict != nil { // Check Parameters & Move Accordingly
            print(parametersDict as Any)
            do {
                // make sure this JSON is in the format we expect
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parametersDict as Any, options: .fragmentsAllowed)
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            
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
    
    static func userRegister(queryParameters: NSDictionary, completion: @escaping (Result<RegistrationModel, Error>) -> Void) {
        // Call Login API with API Router
        performRequest(methodandpath: MethodNameandPath.userRegister, parametersDict: queryParameters, completion: completion)
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
}

extension Dictionary {
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func printJson() {
        print(json)
    }
}
