//
//	Container.swift
//
//	Create by Mukesh Yadav on 5/4/2022

import Foundation

public struct CGContainer: Codable{

	var android : CGAndroid!
	var bannerId : String!
	var height : String!
	var ios : CGAndroid!
	var position : String!
	var type : String!
	var width : String!
    var borderRadius: String!
    
    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		if let androidData = dictionary["android"] as? [String:Any]{
				android = CGAndroid(fromDictionary: androidData)
			}
        bannerId = dictionary["bannerId"] as? String
		height = dictionary["height"] as? String
		if let iosData = dictionary["ios"] as? [String:Any]{
				ios = CGAndroid(fromDictionary: iosData)
			}
		position = dictionary["position"] as? String
		type = dictionary["type"] as? String
		width = dictionary["width"] as? String
        borderRadius = dictionary["borderRadius"] as? String
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if android != nil{
			dictionary["android"] = android.toDictionary()
		}
		if bannerId != nil{
			dictionary["bannerId"] = bannerId
		}
		if height != nil{
			dictionary["height"] = height
		}
		if ios != nil{
			dictionary["ios"] = ios.toDictionary()
		}
		if position != nil{
			dictionary["position"] = position
		}
		if type != nil{
			dictionary["type"] = type
		}
		if width != nil{
			dictionary["width"] = width
		}
        if borderRadius != nil{
            dictionary["borderRadius"] = borderRadius
        }
		return dictionary
	}

}
