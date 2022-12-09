//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/10/21.
//

import Foundation

struct CGConstants {
    static let ERROR = "CUSTOMERGLU Error:"
    static let JSON_ERROR = "CUSTOMERGLU: json parsing error:"
    static let CUSTOMERGLU_TOKEN = "CustomerGlu_Token_Encrypt"
    static let CUSTOMERGLU_USERID = "CustomerGlu_user_id_Encrypt"
    static let DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ssZ"
    static let Analitics_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let MIDDLE_NOTIFICATIONS = "middle-default"
    static let FULL_SCREEN_NOTIFICATION = "full-default"
    static let BOTTOM_SHEET_NOTIFICATION = "bottom-slider"
    static let BOTTOM_DEFAULT_NOTIFICATION = "bottom-default"
    static let MIDDLE_NOTIFICATIONS_POPUP = "middle-popup"
    static let BOTTOM_DEFAULT_NOTIFICATION_POPUP     = "bottom-popup"
    static let FCM_APN = "fcm_apn"
    static let CustomerGluCrash = "CustomerGluCrash_Encrypt"
    static let CustomerGluPopupDict = "CustomerGluPopupDict_Encrypt"
    static let CUSTOMERGLU_ANONYMOUSID = "CustomerGluAnonymousId_Encrypt"
    static let CUSTOMERGLU_USERDATA = "CustomerGluUserData_Encrypt"

    
    static let CUSTOMERGLU_TOKEN_OLD = "CustomerGlu_Token"
    static let CUSTOMERGLU_USERID_OLD = "CustomerGlu_user_id"
    static let CustomerGluCrash_OLD = "CustomerGluCrash"
    static let CustomerGluPopupDict_OLD = "CustomerGluPopupDict"
    
    static let default_whitelist_doamin = "customerglu.com"
    static var default_redirect_url = "https://end-user-ui.customerglu.com/error/?source=native-sdk&"
    static let customerglu_encryptedKey = "customerglu_encryptedKey"
    static let CGOPENWALLET = "CG-OPEN-WALLET"
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
    static let cgsdkversionvalue = "2.1.2"
    static let analytics_version_value = "4.1.0"
    static let analytics_version = "analytics_version"
    static let dismiss_trigger = "dismiss_trigger"
    static let webview_content = "webview_content"
    static let webview_url = "webview_url"
    static let webview_layout = "webview_layout"
    static let absolute_height = "absolute_height"
    static let relative_height = "relative_height"
    static let platform_details = "platform_details"
    static let device_type = "device_type"
    static let os = "os"
    static let app_platform = "app_platform"
    static let sdk_version = "sdk_version"
    static let messagekey = "message"
    
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
    static let absoluteHeight = "absoluteHeight"
    static let relativeHeight = "relativeHeight"
    static let closeOnDeepLink = "closeOnDeepLink"
}

// Default WebViewsKey
struct WebViewsKey {
    static let callback = "callback"
    static let close = "CLOSE"
    static let open_deeplink = "OPEN_DEEPLINK"
    static let analytics = "ANALYTICS"
    static let share = "SHARE"
    static let updateheight = "DIMENSIONS_UPDATE"
}

// TableView Identifiers Used Throught App
struct TableViewID {
    static let BannerCell = "BannerCell"
}

// Default WebViewsKey
struct CGDismissAction {
    static let PHYSICAL_BUTTON = "PHYSICAL_BUTTON"
    static let UI_BUTTON = "UI_BUTTON"
    static let CTA_REDIRECT = "CTA_REDIRECT"
    static let DEFAULT = "DEFAULT"
}
