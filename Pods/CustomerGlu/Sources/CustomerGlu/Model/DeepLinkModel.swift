//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/07/21.
//

import Foundation

struct DeepLinkModel: Codable {
    var eventName = ""
    var data: EventLinkData?
}

struct EventLinkData: Codable {
    var name: String?
    var deepLink: String?
}
