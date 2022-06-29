//
//	Data.swift
//
//	Create by Mukesh Yadav on 5/4/2022

import Foundation

public struct CGData: Codable{

	var v : Int!
	var _id : String!
	var client : String!
	var consumer : String!
	var createdAt : String!
	var mobile : CGMobile!
	var status : String!
	var updatedAt : String!
	var visible : Bool!

	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		v = dictionary["__v"] as? Int
        _id = dictionary["_id"] as? String
		client = dictionary["client"] as? String
		consumer = dictionary["consumer"] as? String
		createdAt = dictionary["createdAt"] as? String
		if let mobileData = dictionary["mobile"] as? [String:Any]{
				mobile = CGMobile(fromDictionary: mobileData)
			}
		status = dictionary["status"] as? String
		updatedAt = dictionary["updatedAt"] as? String
		visible = dictionary["visible"] as? Bool
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if v != nil{
			dictionary["__v"] = v
		}
		if _id != nil{
			dictionary["_id"] = _id
		}
		if client != nil{
			dictionary["client"] = client
		}
		if consumer != nil{
			dictionary["consumer"] = consumer
		}
		if createdAt != nil{
			dictionary["createdAt"] = createdAt
		}
		if mobile != nil{
			dictionary["mobile"] = mobile.toDictionary()
		}
		if status != nil{
			dictionary["status"] = status
		}
		if updatedAt != nil{
			dictionary["updatedAt"] = updatedAt
		}
		if visible != nil{
			dictionary["visible"] = visible
		}
		return dictionary
	}

}
