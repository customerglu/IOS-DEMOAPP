//
//	Content.swift
//
//	Create by Mukesh Yadav on 5/4/2022

import Foundation

public struct CGContent: Codable{

	var _id : String!
	var campaignId : String!
	var openLayout : String!
	var type : String!
	var url : String!
    
    var relativeHeight : Double? = 0.0
    var absoluteHeight : Double? = 0.0
    var closeOnDeepLink : Bool? = CustomerGlu.auto_close_webview!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
        _id = dictionary["_id"] as? String
		campaignId = dictionary["campaignId"] as? String
		openLayout = dictionary["openLayout"] as? String
		type = dictionary["type"] as? String
		url = dictionary["url"] as? String
        if(dictionary["relativeHeight"] != nil){
            relativeHeight = dictionary["relativeHeight"] as? Double
        }
        if(dictionary["absoluteHeight"] != nil){
            absoluteHeight = dictionary["absoluteHeight"] as? Double
        }
        if(dictionary["closeOnDeepLink"] != nil){
            closeOnDeepLink = dictionary["closeOnDeepLink"] as? Bool
        }

	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if _id != nil{
			dictionary["_id"] = _id
		}
		if campaignId != nil{
			dictionary["campaignId"] = campaignId
		}
		if openLayout != nil{
			dictionary["openLayout"] = openLayout
		}
		if type != nil{
			dictionary["type"] = type
		}
		if url != nil{
			dictionary["url"] = url
		}
        
        if relativeHeight != nil{
            dictionary["relativeHeight"] = relativeHeight
        }
        if absoluteHeight != nil{
            dictionary["absoluteHeight"] = absoluteHeight
        }
        if closeOnDeepLink != nil{
            dictionary["closeOnDeepLink"] = closeOnDeepLink
        }
		return dictionary
	}

}
