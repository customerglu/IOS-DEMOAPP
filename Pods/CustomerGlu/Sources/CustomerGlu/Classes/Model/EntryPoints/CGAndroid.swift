//
//	Android.swift
//
//	Create by Mukesh Yadav on 5/4/2022

import Foundation

public struct CGAndroid: Codable{

	var allowedActitivityList : [String]!
	var disallowedActitivityList : [String]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		allowedActitivityList = dictionary["allowedActitivityList"] as? [String]
		disallowedActitivityList = dictionary["disallowedActitivityList"] as? [String]
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if allowedActitivityList != nil{
			dictionary["allowedActitivityList"] = allowedActitivityList
		}
		if disallowedActitivityList != nil{
			dictionary["disallowedActitivityList"] = disallowedActitivityList
		}
		return dictionary
	}

}
