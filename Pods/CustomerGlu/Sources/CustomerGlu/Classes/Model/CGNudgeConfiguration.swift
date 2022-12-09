//
//  File.swift
//  
//
//  Created by kapil on 29/10/21.
//

import Foundation

@objc(CGNudgeConfiguration)
public class CGNudgeConfiguration:NSObject {
        
    public var closeOnDeepLink = CustomerGlu.auto_close_webview!
    public var opacity = 0.5
    public var layout = ""
    public var url = ""
    public var absoluteHeight = 0.0
    public var relativeHeight = 0.0
//    public var notificationHandler = false
    
    public override init() {

    }
    
    public init(closeOnDeepLink : Bool = CustomerGlu.auto_close_webview!, opacity : Double = 0.5, layout : String = "",url : String = "", absoluteHeight : Double = 0.0, relativeHeight : Double = 0.0/*, notificationHandler : Bool = false*/) {
        
        self.closeOnDeepLink = closeOnDeepLink
        self.opacity = opacity
        self.layout = layout
        self.url = url
        self.absoluteHeight = absoluteHeight
        self.relativeHeight = relativeHeight
//        self.notificationHandler = notificationHandler
    }

}
