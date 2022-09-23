//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 22/07/21.
//

import Foundation

@objc(CGRegistrationModel)
public class CGRegistrationModel: NSObject, Codable {
          public var success: Bool?
    @objc public var data: CGMyData?
}

@objc(CGMyData)
public class CGMyData: NSObject, Codable {
    @objc public var token: String?
    @objc public var user: CGUser?
}

@objc(CGUser)
public class CGUser: NSObject, Codable {
    @objc public var id: String?
    @objc public var userId: String?
    @objc public var anonymousId: String?
    @objc public var gluId: String?
    @objc public var userName: String?
    @objc public var email: String?
    @objc public var phone: String?
    @objc public var cookieId: String?
    @objc public var appVersion: String?
    @objc public var client: String?
    @objc public var referralLink: String?
    @objc public var referredBy: String?
    @objc public var identities: CGIdentities?
    @objc public var profile: CGProfile?
    @objc public var sessionId: String?
    @objc public var deviceId: String?
    @objc public var deviceType: String?
    @objc public var deviceName: String?
}

@objc(CGIdentities)
public class CGIdentities: NSObject, Codable {
    @objc public var facebook_id: String?
    @objc public var google_id: String?
    @objc public var android_id: String?
    @objc public var ios_id: String?
    @objc public var clevertap_id: String?
    @objc public var mparticle_id: String?
    @objc public var segment_id: String?
    @objc public var moengage_id: String?
}

@objc(CGProfile)
public class CGProfile: NSObject, Codable {
    @objc public var firstName: String?
    @objc public var lastName: String?
    @objc public var age: String?
    @objc public var city: String?
    @objc public var country: String?
    @objc public var timezone: String?
}
