//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/10/21.
//

import Foundation

struct Constants {
    static let ERROR = "CUSTOMERGLU Error:"
    static let JSON_ERROR = "CUSTOMERGLU: json parsing error:"
    static let CUSTOMERGLU_TOKEN = "CustomerGlu_Token"
    static let CUSTOMERGLU_USERID = "CustomerGlu_user_id"
    static let DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ssZ"
    static let MIDDLE_NOTIFICATIONS = "middle-default"
    static let FULL_SCREEN_NOTIFICATION = "full-default"
    static let BOTTOM_SHEET_NOTIFICATION = "bottom-slider"
    static let BOTTOM_DEFAULT_NOTIFICATION = "bottom-default"
    static let WalletRewardData = "WalletRewardData"
}

// Default APIParameterKey
struct APIParameterKey {
    static let deviceId = "deviceId"
    static let deviceType = "deviceType"
    static let deviceName = "deviceName"
    static let appVersion = "appVersion"
    static let writeKey = "writeKey"
    static let event_id = "event_id"
    static let event_name = "event_name"
    static let user_id = "user_id"
    static let timestamp = "timestamp"
    static let event_properties = "event_properties"
    static let userId = "userId"
    static let bearer = "Bearer"
    
}

// Default NotificationsKey
struct NotificationsKey {
    static let type = "type"
    static let customerglu = "customerglu"
    static let glu_message_type = "glu_message_type"
    static let in_app = "in-app"
    static let nudge_url = "nudge_url"
    static let page_type = "page_type"
    static let CustomerGlu = "CustomerGlu"
}

// Default WebViewsKey
struct WebViewsKey {
    static let callback = "callback"
    static let close = "CLOSE"
    static let open_deeplink = "OPEN_DEEPLINK"
    static let share = "SHARE"
}

// TableView Identifiers Used Throught App
struct TableViewID {
    static let BannerCell = "BannerCell"
}
