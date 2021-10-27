//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/10/21.
//

import Foundation

public class NetworkCall: ObservableObject {
    var constant = Constants()
    @Published var apidata = RegistrationModel()
    @Published var campaigndata = CampaignsModel()
    
    public func getData(url: String) {
        let customer_token = UserDefaults.standard.string(forKey: self.constant.CUSTOMERGLU_TOKEN)
        let token = "Bearer "+customer_token!
        let myurl = URL(string: url)
        var request = URLRequest(url: myurl!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(response as Any)
            if error == nil && data != nil {
                do {
                    let mydata = try JSONDecoder().decode(CampaignsModel.self, from: data!)
                    print("data")
                    DispatchQueue.main.async {
                        self.campaigndata = mydata
                        //  completion(self.campaigndata)
                        print(self.campaigndata)
                    }
                } catch {
                    print(self.constant.ERROR+"\(error)")
                }
                //   } catch  {
                //   print("error: \(error)")
                //   }
            }
        }.resume()
    }
    
    public func postData(url: String, body: [String: AnyHashable]) {
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let myurl = URL(string: self.constant.DEVICE_REGISTER)
        var request = URLRequest(url: myurl!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(response as Any)
            if error == nil && data != nil {
                do {
                    let dictonary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    as? [String: Any]
                    print(dictonary as Any)
                    do {
                        let mydata = try JSONDecoder().decode(RegistrationModel.self, from: data!)
                        print("data")
                        print("-------------------")
                        DispatchQueue.main.async {
                            self.apidata = mydata
                            let token = self.apidata.data?.token
                            UserDefaults.standard.set(token, forKey: self.constant.CUSTOMERGLU_TOKEN)
                            let user_id = self.apidata.data?.token
                            UserDefaults.standard.set(user_id, forKey: self.constant.CUSTOMERGLU_USERID)
                            //    completion(self.apidata)
                        }
                    } catch {
                        print(self.constant.JSON_ERROR+"\(error)")
                    }
                } catch {
                    print(self.constant.ERROR+"\(error)")
                }
            }
        }.resume()
    }
}
