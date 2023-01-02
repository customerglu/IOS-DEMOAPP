//
//	CGDeeplink.swift
//
//	Create by Mukesh Yadav on 20/12/2022

import Foundation
import UIKit

@objc(CGDeeplink)
public class CGDeeplink: NSObject,Codable {

	var data: CGDeeplinkData?
	var message: String?
	var success: Bool?


}

@objc(CGDeeplinkData)
public class CGDeeplinkData: NSObject,Codable {

    var anonymous: Bool?
    var client: String?
    var container: CGDeepContainer?
    var content: CGDeepContent?


}

@objc(CGDeepContent)
public class CGDeepContent: NSObject, Codable {

    var campaignId: String? = ""
    var closeOnDeepLink: Bool? = CustomerGlu.auto_close_webview
    var type: String? = ""
    var url: String? = ""


}

@objc(CGDeepContainer)
public class CGDeepContainer: NSObject, Codable {

    var absoluteHeight: Double? = 0.0
    var relativeHeight: Double? = 0.0
    var type: String? = ""

}
