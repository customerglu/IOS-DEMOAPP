//
//  File.swift
//  
//
//  Created by kapil on 01/11/21.
//

import Foundation

class DebugLogger {
    
    // Singleton Instance
    static let sharedInstance = DebugLogger()
    
    private var isEnabled = true
    private var appVersion = ""
    
    func debugLogger(appVersion: String) {
        self.appVersion = appVersion
    }
    
    func debugLogger(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    class func log(funcName: String, code: String, timeStamp: String) -> String {
        return "\n\(funcName) \(code) \(timeStamp)"
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setErrorDebugLogger(functionName: String, description: String = "", exception: String = "", code: String = "") {
        print("exception : \(exception)")
        /*
        if isEnabled {
            _ = Date()
            let timestamp = "dd MMM yyyy"
            var fileSize: UInt64
            do {
                let filePath = DebugLogger.getDocumentsDirectory().appendingPathComponent("DebugLogger.csv")
                let attr = try FileManager.default.attributesOfItem(atPath: filePath.path)
                fileSize = attr[FileAttributeKey.size] as? UInt64 ?? 0
                if 10 < (fileSize / (1024 * 1024)) {
                    do {
                        try FileManager.default.removeItem(at: filePath)
                    } catch {
                    }
                }
            } catch {
                print("Error: \(error)")
            }
            writeErrorDebugLogger(functionName: functionName, code: "11144", timestamp: timestamp)
        }*/
    }
    
    private func writeErrorDebugLogger(functionName: String, code: String, timestamp: String) {
        
        let message = DebugLogger.log(funcName: "\(functionName),", code: "\(code),", timeStamp: "\(timestamp)")
        
        let filename = DebugLogger.getDocumentsDirectory().appendingPathComponent("DebugLogger.csv")
        if FileManager.default.fileExists(atPath: filename.path) {
            do {
                let fileHandle = try FileHandle(forWritingTo: filename)
                fileHandle.seekToEndOfFile()
                fileHandle.write(message.data(using: .utf8)!)
                fileHandle.closeFile()
            } catch {
                print("Some error occur")
            }
        } else {
            do {
                let msAppversion = "App Version \(1.0)"
                let msg = DebugLogger.log(funcName: "Function Name,", code: "Exception Code,", timeStamp: "Timestamp")
                try msAppversion.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                let fileHandle = try FileHandle(forWritingTo: filename)
                fileHandle.seekToEndOfFile()
                fileHandle.write(msg.data(using: .utf8)!)
                fileHandle.write(message.data(using: .utf8)!)
                fileHandle.closeFile()
            } catch {
                print("Some error occur")
            }
        }
    }
}
