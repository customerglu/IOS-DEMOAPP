//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/07/21.
//

import Foundation

class CGDeepLinkModel: Codable {
    var eventName = ""
    var data: CGEventLinkData?
}

class CGEventLinkData: Codable {
    var name: String?
    var deepLink: String?
}
