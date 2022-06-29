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
    static let Analitics_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let MIDDLE_NOTIFICATIONS = "middle-default"
    static let FULL_SCREEN_NOTIFICATION = "full-default"
    static let BOTTOM_SHEET_NOTIFICATION = "bottom-slider"
    static let BOTTOM_DEFAULT_NOTIFICATION = "bottom-default"
    static let FCM_APN = "fcm_apn"
    static let CustomerGluCrash = "CustomerGluCrash"
    static let CustomerGluPopupDict = "CustomerGluPopupDict"
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
    static let apnsDeviceToken = "apnsDeviceToken"
    static let firebaseToken = "firebaseToken"
    static let campaign_id = "campaign_id"
    static let type = "type"
    static let status = "status"
    static let stack_trace = "stack_trace"
    static let method = "method"
    static let version = "version"
    static let app_name = "app_name"
    static let device_name = "device_name"
    static let os_version = "os_version"
    static let app_version = "app_version"
    static let platform = "platform"
    static let device_id = "device_id"
    static let timezone = "timezone"
    static let pageName = "pageName"
    static let nudgeType = "nudgeType"
    static let nudgeId = "nudgeId"
    static let actionName = "actionName"
    static let actionType = "actionType"
    static let actionTarget = "actionTarget"
    static let pageType = "pageType"
    static let campaignId = "campaignId"
    static let activityIdList = "activityIdList"
    static let eventId = "eventId"
    static let optionalPayload = "optionalPayload"
    static let appSessionId = "appSessionId"
    static let userAgent = "userAgent"
    static let eventName = "eventName"

    
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
    static let analytics = "ANALYTICS"
    static let share = "SHARE"
}

// TableView Identifiers Used Throught App
struct TableViewID {
    static let BannerCell = "BannerCell"
}
