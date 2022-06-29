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


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
        _id = dictionary["_id"] as? String
		campaignId = dictionary["campaignId"] as? String
		openLayout = dictionary["openLayout"] as? String
		type = dictionary["type"] as? String
		url = dictionary["url"] as? String
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
		return dictionary
	}

}
