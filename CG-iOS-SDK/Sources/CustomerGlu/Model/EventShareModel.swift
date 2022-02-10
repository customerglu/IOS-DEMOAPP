//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/07/21.
//

import Foundation

struct EventShareModel: Codable {
    var eventName = ""
    var data: EventShareData?
}

struct EventShareData: Codable {
    var channelName = ""
    var text = ""
    var image = ""
}
