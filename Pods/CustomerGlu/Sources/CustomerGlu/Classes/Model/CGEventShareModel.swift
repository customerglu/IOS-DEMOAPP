//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/07/21.
//

import Foundation

class CGEventShareModel: Codable {
    var eventName = ""
    var data: CGEventShareData?
}

class CGEventShareData: Codable {
    var channelName = ""
    var text = ""
    var image = ""
}
