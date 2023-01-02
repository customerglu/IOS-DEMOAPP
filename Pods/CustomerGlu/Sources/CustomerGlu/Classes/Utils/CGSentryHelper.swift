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
        SentrySDK.start { options in
                options.dsn = "https://d8f227fc976a44d39423a88712307abb@o4504359069483008.ingest.sentry.io/4504364372525056"
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
    
    func captureExceptionEvent(exceptionLog: String){
        let exception =  NSError(domain: exceptionLog, code: 0, userInfo: nil)
        SentrySDK.capture(error: exception)
    }
    
    
    
}
