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
    case platform = "platform"
    case xgluauth = "X-GLU-AUTH"
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
    static let entryPointdata = MethodandPath(method: "GET", path: "entrypoints/v1/list?consumer=MOBILE")
    static let publish_nudge = MethodandPath(method: "POST", path: "v4/nudge")
    static let entrypoints_config = MethodandPath(method: "POST", path: "entrypoints/v1/config")
}

// Parameter Key's for all API's
private struct BaseUrls {
    static let baseurl = ApplicationManager.baseUrl
    static let streamurl = ApplicationManager.streamUrl
    static let analyticsUrl = ApplicationManager.analyticsUrl
}

// Class contain Helper Methods Used in Overall Application Related to API Calls
class APIManager {
    
    public var session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // Singleton Instance
    static let shared = APIManager()
    
    private static func performRequest<T: Decodable>(baseurl: String, methodandpath: MethodandPath, parametersDict: NSDictionary?,dispatchGroup:DispatchGroup = DispatchGroup() ,completion: @escaping (Result<T, Error>) -> Void) {
        
        //Grouped compelete API-call work flow into a DispatchGroup so that it can maintanted the oprational queue for task completion
        // Enter into DispatchGroup
        //   if(MethodNameandPath.getWalletRewards.path == methodandpath.path){
        dispatchGroup.enter()
        //    }
        
        var urlRequest: URLRequest!
        var url: URL!
        let strUrl = "https://" + baseurl
        url = URL(string: strUrl + methodandpath.path)!
        urlRequest = URLRequest(url: url)
        if(true == CustomerGlu.isDebugingEnabled){
            print(urlRequest!)
        }
        
        // HTTP Method
        urlRequest.httpMethod = methodandpath.method//method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        if UserDefaults.standard.object(forKey: Constants.CUSTOMERGLU_TOKEN) != nil {
            urlRequest.setValue("\(APIParameterKey.bearer) " + CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: Constants.CUSTOMERGLU_TOKEN), forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
            urlRequest.setValue("\(APIParameterKey.bearer) " + CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: Constants.CUSTOMERGLU_TOKEN), forHTTPHeaderField: HTTPHeaderField.xgluauth.rawValue)
            urlRequest.setValue(Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String, forHTTPHeaderField: HTTPHeaderField.xapikey.rawValue)
            urlRequest.setValue("ios", forHTTPHeaderField: HTTPHeaderField.platform.rawValue)
        }
        
        if parametersDict!.count > 0 { // Check Parameters & Move Accordingly
            
            if(true == CustomerGlu.isDebugingEnabled){
                print(parametersDict as Any)
            }
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
        
        let task = shared.session.dataTask(with: urlRequest) { data, response, error in
            
            // Leave from dispachgroup
            // wait untill dispatchGroup.leave() not called
            // if(MethodNameandPath.getWalletRewards.path == methodandpath.path){
            dispatchGroup.leave()
            //  }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    CustomerGlu.getInstance.clearGluData()
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
                if(true == CustomerGlu.isDebugingEnabled){
                    print(error)
                }
                
            }
        }
        task.resume()
        
        // wait untill dispatchGroup.leave() not called
        //  if(MethodNameandPath.getWalletRewards.path == methodandpath.path){
        dispatchGroup.wait()
        //   }
    }
    
    static func userRegister(queryParameters: NSDictionary, completion: @escaping (Result<RegistrationModel, Error>) -> Void) {
        // create a blockOperation for avoiding miltiple API call at same time
        let blockOperation = BlockOperation()
        
        // Added Task into Queue
        blockOperation.addExecutionBlock {
        // Call Login API with API Router
            performRequest(baseurl: BaseUrls.baseurl, methodandpath: MethodNameandPath.userRegister, parametersDict: queryParameters, completion: completion)
        }
        
        // Add dependency to finish previus task before starting new one
        if(ApplicationManager.operationQueue.operations.count > 0){
            blockOperation.addDependency(ApplicationManager.operationQueue.operations.last!)
        }
         
         //Added task into Queue
         ApplicationManager.operationQueue.addOperation(blockOperation)
    }
    
    static func getWalletRewards(queryParameters: NSDictionary, completion: @escaping (Result<CampaignsModel, Error>) -> Void) {
        // Call Get Wallet and Rewards List

        // create a blockOperation for avoiding miltiple API call at same time
        let blockOperation = BlockOperation()
        
        // Added Task into Queue
        blockOperation.addExecutionBlock {
            performRequest(baseurl: BaseUrls.baseurl, methodandpath: MethodNameandPath.getWalletRewards, parametersDict: queryParameters,completion: completion)
        }
        
       // Add dependency to finish previus task before starting new one
       if(ApplicationManager.operationQueue.operations.count > 0){
           blockOperation.addDependency(ApplicationManager.operationQueue.operations.last!)
       }
        
        //Added task into Queue
        ApplicationManager.operationQueue.addOperation(blockOperation)
    }
    
    static func addToCart(queryParameters: NSDictionary, completion: @escaping (Result<AddCartModel, Error>) -> Void) {
        
        // create a blockOperation for avoiding miltiple API call at same time
        let blockOperation = BlockOperation()
        
        // Added Task into Queue
        blockOperation.addExecutionBlock {
            // Call Get Wallet and Rewards List
            performRequest(baseurl: BaseUrls.streamurl, methodandpath: MethodNameandPath.addToCart, parametersDict: queryParameters, completion: completion)
        }
        
        // Add dependency to finish previus task before starting new one
        if(ApplicationManager.operationQueue.operations.count > 0){
            blockOperation.addDependency(ApplicationManager.operationQueue.operations.last!)
        }
        
        //Added task into Queue
        ApplicationManager.operationQueue.addOperation(blockOperation)
    }
    
    static func crashReport(queryParameters: NSDictionary, completion: @escaping (Result<AddCartModel, Error>) -> Void) {
        // create a blockOperation for avoiding miltiple API call at same time
        let blockOperation = BlockOperation()
        
        // Added Task into Queue
        blockOperation.addExecutionBlock {
            // Call Get Wallet and Rewards List
            performRequest(baseurl: BaseUrls.baseurl, methodandpath: MethodNameandPath.crashReport, parametersDict: queryParameters, completion: completion)
        }
        
        // Add dependency to finish previus task before starting new one
        if(ApplicationManager.operationQueue.operations.count > 0){
            blockOperation.addDependency(ApplicationManager.operationQueue.operations.last!)
        }
        
        //Added task into Queue
        ApplicationManager.operationQueue.addOperation(blockOperation)
    }
    
    static func getEntryPointdata(queryParameters: NSDictionary, completion: @escaping (Result<CGEntryPoint, Error>) -> Void) {
        // create a blockOperation for avoiding miltiple API call at same time
        let blockOperation = BlockOperation()
        
        // Added Task into Queue
        blockOperation.addExecutionBlock {
        // Call Get Wallet and Rewards List
            performRequest(baseurl: BaseUrls.baseurl, methodandpath: MethodNameandPath.entryPointdata, parametersDict: queryParameters, completion: completion)
        }
        
        // Add dependency to finish previus task before starting new one
        if(ApplicationManager.operationQueue.operations.count > 0){
            blockOperation.addDependency(ApplicationManager.operationQueue.operations.last!)
        }
        
        //Added task into Queue
        ApplicationManager.operationQueue.addOperation(blockOperation)
    }
    
    static func publishNudge(queryParameters: NSDictionary, completion: @escaping (Result<PublishNudgeModel, Error>) -> Void) {
        // create a blockOperation for avoiding miltiple API call at same time
        let blockOperation = BlockOperation()
        
        // Added Task into Queue
        blockOperation.addExecutionBlock {
        // Call Put PublishNudge
            performRequest(baseurl: BaseUrls.streamurl, methodandpath: MethodNameandPath.publish_nudge, parametersDict: queryParameters, completion: completion)
        }
        
        // Add dependency to finish previus task before starting new one
        if(ApplicationManager.operationQueue.operations.count > 0){
            blockOperation.addDependency(ApplicationManager.operationQueue.operations.last!)
        }
        
        //Added task into Queue
        ApplicationManager.operationQueue.addOperation(blockOperation)
    }
    
    static func entrypoints_config(queryParameters: NSDictionary, completion: @escaping (Result<EntryConfig, Error>) -> Void) {
        // create a blockOperation for avoiding miltiple API call at same time
        let blockOperation = BlockOperation()
        
        // Added Task into Queue
        blockOperation.addExecutionBlock {
        // Call Put EntryPoints_Config
            performRequest(baseurl: BaseUrls.baseurl, methodandpath: MethodNameandPath.entrypoints_config, parametersDict: queryParameters, completion: completion)
        }
        
        // Add dependency to finish previus task before starting new one
        if(ApplicationManager.operationQueue.operations.count > 0){
            blockOperation.addDependency(ApplicationManager.operationQueue.operations.last!)
        }
        
        //Added task into Queue
        ApplicationManager.operationQueue.addOperation(blockOperation)
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

// We create a partial mock by subclassing the original class
class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    var data: Data?
    var error: Error?
    
    override func dataTask(
        with url: URLRequest,
        completionHandler: @escaping CompletionHandler
    ) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        
        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}
