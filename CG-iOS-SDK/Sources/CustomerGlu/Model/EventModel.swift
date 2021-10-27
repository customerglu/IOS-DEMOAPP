//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 24/07/21.
//

import Foundation

struct EventModel: Codable {
    var eventName = ""
    var data: EventData?
}

struct EventData: Codable {
}
