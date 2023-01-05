//
//  File.swift
//  
//
//  Created by Kausthubh adhikari on 23/12/22.
//

import Foundation
import Sentry

public class CGSentryHelper{
    
 static let shared = CGSentryHelper()
    
    func setupSentry(){
        if CustomerGlu.sentry_enable! {
        SentrySDK.start { options in
                options.dsn = "https://d856e4a14b6d4c6eae1fc283d6ddbe8e@o4504440824856576.ingest.sentry.io/4504442660454400"
                // Enabled debug when first installing is always helpful

                // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
                // We recommend adjusting this value in production.
                options.tracesSampleRate = 1.0
                // Features turned off by default, but worth checking out
                options.enableAppHangTracking = true
                options.enableFileIOTracking = true
                options.enableCoreDataTracking = true
                options.enableCaptureFailedRequests = true
            }
       }
    }
    
    func setupUser(userId: String, clientId: String){
        if CustomerGlu.sentry_enable! {
            let user = User()
            user.userId = userId
            user.username = clientId
            SentrySDK.setUser(user)
        }
    }
    
    func logoutSentryUser(){
        if CustomerGlu.sentry_enable! {
            SentrySDK.setUser(nil)
        }
    }
    
    func captureExceptionEvent(exceptionLog: String){
        if CustomerGlu.sentry_enable! {
            let exception =  NSError(domain: exceptionLog, code: 0, userInfo: nil)
            SentrySDK.capture(error: exception)
        }
    }
    
    
    
}
