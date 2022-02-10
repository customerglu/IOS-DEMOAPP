//
//  File.swift
//
//
//  Created by kapil on 15/12/21.
//

import Foundation
import UIKit

//--------------------------------------------------------------------------
// MARK: - CustomerGluCrashDelegate
//--------------------------------------------------------------------------
public protocol CustomerGluCrashDelegate: NSObjectProtocol {
    func customerGluDidCatchCrash(with model: CrashModel)
}

//--------------------------------------------------------------------------
// MARK: - WeakCustomerGluCrashDelegate
//--------------------------------------------------------------------------
class WeakCustomerGluCrashDelegate: NSObject {
    weak var delegate: CustomerGluCrashDelegate?
    
    init(delegate: CustomerGluCrashDelegate) {
        super.init()
        self.delegate = delegate
    }
}

//--------------------------------------------------------------------------
// MARK: - CrashModelType
//--------------------------------------------------------------------------
public enum CrashModelType: Int {
    case signal = 1
    case exception = 2
}

//--------------------------------------------------------------------------
// MARK: - CrashModel
//--------------------------------------------------------------------------
open class CrashModel: NSObject {
    
    public var type: CrashModelType?
    public var name: String?
    public var reason: String?
    public var appinfo: String?
    public var callStack: String?
    
    init(type: CrashModelType,
         name: String,
         reason: String,
         appinfo: String,
         callStack: String) {
        super.init()
        self.type = type
        self.name = name
        self.reason = reason
        self.appinfo = appinfo
        self.callStack = callStack
    }
}

//--------------------------------------------------------------------------
// MARK: - GLOBAL VARIABLE
//--------------------------------------------------------------------------
private var app_old_exceptionHandler:(@convention(c) (NSException) -> Swift.Void)? = nil

//--------------------------------------------------------------------------
// MARK: - CustomerGluCrash
//--------------------------------------------------------------------------
public class CustomerGluCrash: NSObject {
    
    //--------------------------------------------------------------------------
    // MARK: OPEN PROPERTY
    //--------------------------------------------------------------------------
    public private(set) static var isOpen: Bool = false
    
    //--------------------------------------------------------------------------
    // MARK: OPEN FUNCTION
    //--------------------------------------------------------------------------
    open class func add(delegate: CustomerGluCrashDelegate) {
        // delete null week delegate
        self.delegates = self.delegates.filter {
            return $0.delegate != nil
        }
        
        // judge if contains the delegate from parameter
        let contains = self.delegates.contains {
            return $0.delegate?.hash == delegate.hash
        }
        // if not contains, append it with weak wrapped
        if contains == false {
            let week = WeakCustomerGluCrashDelegate(delegate: delegate)
            self.delegates.append(week)
        }
        
        if self.delegates.count > 0 {
            self.open()
        }
    }
    
    open class func remove(delegate: CustomerGluCrashDelegate) {
        self.delegates = self.delegates.filter {
            // filter null weak delegate
            return $0.delegate != nil
            }.filter {
                // filter the delegate from parameter
                return $0.delegate?.hash != delegate.hash
        }
        
        if self.delegates.count == 0 {
            self.close()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE FUNCTION
    //--------------------------------------------------------------------------
    private class func open() {
        guard self.isOpen == false else {
            return
        }
        CustomerGluCrash.isOpen = true
        
        app_old_exceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(CustomerGluCrash.RecieveException)
        self.setCrashSignalHandler()
    }
    
    private class func close() {
        guard self.isOpen == true else {
            return
        }
        CustomerGluCrash.isOpen = false
        NSSetUncaughtExceptionHandler(app_old_exceptionHandler)
    }
    
    private class func setCrashSignalHandler() {
        signal(SIGABRT, CustomerGluCrash.RecieveSignal)
        signal(SIGILL, CustomerGluCrash.RecieveSignal)
        signal(SIGSEGV, CustomerGluCrash.RecieveSignal)
        signal(SIGFPE, CustomerGluCrash.RecieveSignal)
        signal(SIGBUS, CustomerGluCrash.RecieveSignal)
        signal(SIGPIPE, CustomerGluCrash.RecieveSignal)
        //http://stackoverflow.com/questions/36325140/how-to-catch-a-swift-crash-and-do-some-logging
        signal(SIGTRAP, CustomerGluCrash.RecieveSignal)
    }
    
    private static let RecieveException: @convention(c) (NSException) -> Swift.Void = {
        (exteption) -> Void in
        if app_old_exceptionHandler != nil {
            app_old_exceptionHandler!(exteption)
        }

        guard CustomerGluCrash.isOpen == true else {
            return
        }

        let callStack = exteption.callStackSymbols.joined(separator: "\r")
        let reason = exteption.reason ?? ""
        let name = exteption.name
        let appinfo = CustomerGluCrash.appInfo()
        
        let jsonData = try? JSONSerialization.data(withJSONObject: appinfo, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        
        let model = CrashModel(type: CrashModelType.exception,
                               name: name.rawValue,
                               reason: reason,
                               appinfo: jsonString!,
                               callStack: callStack)

        for delegate in CustomerGluCrash.delegates {
            delegate.delegate?.customerGluDidCatchCrash(with: model)
        }
    }
    
    private static let RecieveSignal : @convention(c) (Int32) -> Void = {
        (signal) -> Void in
        
        guard CustomerGluCrash.isOpen == true else {
            return
        }
        
        var stack = Thread.callStackSymbols
        stack.removeFirst(2)
        let callStack = stack.joined(separator: "\r")
        let reason = "Signal \(CustomerGluCrash.name(of: signal))(\(signal)) was raised.\n"
        let appinfo = CustomerGluCrash.appInfo()
        
        let jsonData = try? JSONSerialization.data(withJSONObject: appinfo, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        
        let model = CrashModel(type: CrashModelType.signal,
                               name: CustomerGluCrash.name(of: signal),
                               reason: reason,
                               appinfo: jsonString!,
                               callStack: callStack)
        
        for delegate in CustomerGluCrash.delegates {
            delegate.delegate?.customerGluDidCatchCrash(with: model)
        }
        
        CustomerGluCrash.killApp()
    }
    
    private class func appInfo() -> Dictionary<String, Any> {
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let osName = UIDevice.current.systemName
        let udid = UIDevice.current.identifierForVendor?.uuidString
        let timestamp = Date.currentTimeStamp
        let timezone = TimeZone.current.abbreviation()!

        let dict = ["app_name": displayName, "device_name": deviceModel, "os_version": "\(systemName) \(systemVersion)", "app_version": "\(shortVersion)(\(version))", "platform": osName, "device_id": udid!, "timestamp": timestamp, "timezone": timezone] as [String: Any]
        return dict
    }
    
    private class func name(of signal: Int32) -> String {
        switch signal {
        case SIGABRT:
            return "SIGABRT"
        case SIGILL:
            return "SIGILL"
        case SIGSEGV:
            return "SIGSEGV"
        case SIGFPE:
            return "SIGFPE"
        case SIGBUS:
            return "SIGBUS"
        case SIGPIPE:
            return "SIGPIPE"
        default:
            return "OTHER"
        }
    }
    
    private class func killApp() {
        NSSetUncaughtExceptionHandler(nil)
        
        signal(SIGABRT, SIG_DFL)
        signal(SIGILL, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        signal(SIGPIPE, SIG_DFL)
        
        kill(getpid(), SIGKILL)
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTY
    //--------------------------------------------------------------------------
    fileprivate static var delegates = [WeakCustomerGluCrashDelegate]()
}
