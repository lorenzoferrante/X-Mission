//
//  Utils.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/6/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import Foundation

public enum LogType: String {
    case INFO = "[INFO]"
    case DEBUG = "[DEBUG]"
    case ERROR = "[ERROR]"
}

public enum LogMessage: String {
    case StartedClient = "Client started"
    case Connected = "Connected to server"
    case TorrentAdded = "Added torrent"
    case TorrentRemoved = "Removed torrent"
    case GotStatusCode = "Got statusCode"
    case GenericError = "Generic error"
    case StoppedClient = "Cliente stopped"
    case RequestedTorrent = "Torrent list requested"
    case TorrentPaused = "TorrentPaused"
    case NeedSessionId = "Gettin X-Transmission-Session-ID"
    case UpdateUserDefaults = "Updated setting"
}

final class Utils {
    
    static let FIRST_LAUNCH = "first_launch"
    static let LOG_KEY = "log"
    static let IP = "ip"
    static let PORT = "port"
    static let PATH = "path"
    static let USER = "user"
    static let PWD = "pwd"
    static let REFRESH = "refresh"
    
    static let shared = Utils()
    
    // MARK:- Methods
    public func setFirstLaunch() {
        if UserDefaults.standard.bool(forKey: Utils.FIRST_LAUNCH) {
            UserDefaults.standard.set(true, forKey: Utils.FIRST_LAUNCH)
        } else {
            UserDefaults.standard.set(true, forKey: Utils.FIRST_LAUNCH)
        }
    }
    
    public func populateUserDefaults() {
        if UserDefaults.standard.value(forKey: Utils.IP) == nil {
            UserDefaults.standard.set("127.0.0.1", forKey: Utils.IP)
        }
        
        if UserDefaults.standard.value(forKey: Utils.PORT) == nil {
            UserDefaults.standard.set("9091", forKey: Utils.PORT)
        }
        
        if UserDefaults.standard.value(forKey: Utils.PATH) == nil {
            UserDefaults.standard.set("/transmission/rpc", forKey: Utils.PATH)
        }
        
        if UserDefaults.standard.value(forKey: Utils.USER) == nil {
            UserDefaults.standard.set("admin", forKey: Utils.USER)
        }
        
        if UserDefaults.standard.value(forKey: Utils.PWD) == nil {
            UserDefaults.standard.set("admin", forKey: Utils.PWD)
        }
        
        if UserDefaults.standard.value(forKey: Utils.REFRESH) == nil {
            UserDefaults.standard.set(3, forKey: Utils.REFRESH)
        }
    }
    
    public func didSetUserDefault(_ type: String, val: Any) {
        switch type {
        case Utils.IP:
            UserDefaults.standard.set(val, forKey: Utils.IP)
        case Utils.PORT:
            UserDefaults.standard.set(val, forKey: Utils.PORT)
        case Utils.PATH:
            UserDefaults.standard.set(val, forKey: Utils.PATH)
        case Utils.USER:
            UserDefaults.standard.set(val, forKey: Utils.USER)
        case Utils.PWD:
            UserDefaults.standard.set(val, forKey: Utils.PWD)
        case Utils.REFRESH:
            UserDefaults.standard.set(val, forKey: Utils.REFRESH)
        default:
            break
        }
        self.log(msgType: .UpdateUserDefaults, type: .DEBUG)
    }
    
    public func log(_ msg: String? = nil, msgType: LogMessage, type: LogType) {
        let date = "[\(getDate())]"
        if let logs = UserDefaults.standard.value(forKey: Utils.LOG_KEY) as? String {
            var newLogs = logs
            newLogs.append("\(date) \(type.rawValue) \(msgType.rawValue) \(msg != nil ? msg! : "")\n")
            UserDefaults.standard.set(newLogs, forKey: Utils.LOG_KEY)
        } else {
            UserDefaults.standard.set("\(date) \(type.rawValue) \(msg != nil ? msg! : "")\n", forKey: Utils.LOG_KEY)
        }
        NotificationCenter.default.post(name: .didGotNewLog, object: nil)
        return NSLog("\(type.rawValue) \(msg != nil ? msg! : "")")
    }
    
    private func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
        
    }
    
    public func formatLogs(_ logs: String) -> String {
        return logs.split(separator: "\n").reversed().joined(separator: "\n")
    }
    
}
