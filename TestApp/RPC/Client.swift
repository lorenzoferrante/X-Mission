//
//  Client.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/4/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import Foundation
import UIKit

class RPCCLient: NSObject {
    
    static let shared = RPCCLient()
    
    lazy var baseURL: String! = {
        return "http://\(self.ip!):\(self.port!)\(self.path!)"
    }()
    var sessionID = "NLTdlIrUohdOOEI6EzrB7ahZfXLLTViFN59I0XoWW3tccccZ4iB"
    var timer: Timer!
    var appliedFilter: Filter = .ALL
    
    // UserDefault
    var ip: String!
    var port: String!
    var path: String!
    var user: String!
    var pwd: String!
    var refresh: Int!
    
    var delegate: RPCClienteDelegate!
    
    lazy var loginEncoded: String = {
        let loginString = "\(self.user!):\(self.pwd!)"
        let loginData = loginString.data(using: .utf8)!
        return loginData.base64EncodedString()
    }()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didGotMagnetLink(_:)), name: .didGotMagnetLink, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserDefaults), name: .userDefaultNeedUpdate, object: nil)
        
        getUserDefaults()
        Utils.shared.log(msgType: .StartedClient, type: .INFO)
    }
    
    // MARK:- Methods    
    private func getUserDefaults() {
        ip = UserDefaults.standard.value(forKey: Utils.IP) as? String
        port = UserDefaults.standard.value(forKey: Utils.PORT) as? String
        path = UserDefaults.standard.value(forKey: Utils.PATH) as? String
        user = UserDefaults.standard.value(forKey: Utils.USER) as? String
        pwd = UserDefaults.standard.value(forKey: Utils.PWD) as? String
        refresh = UserDefaults.standard.value(forKey: Utils.REFRESH) as? Int
        
        baseURL = "http://\(self.ip!):\(self.port!)\(self.path!)"
        reloadLoginData(user: user!, pwd: pwd!)
        startBackgroundThread()
    }
    
    private func reloadLoginData(user: String, pwd: String) {
        let loginString = "\(user):\(pwd)"
        let loginData = loginString.data(using: .utf8)!
        self.loginEncoded = loginData.base64EncodedString()
    }
    
    public func startBackgroundThread() {
        if timer != nil {
            if timer.isValid {
                stopBackgroundThread()
            }
        }
        
        Utils.shared.log(msgType: .StartedClient, type: .INFO)
        timer = Timer.scheduledTimer(withTimeInterval: Double(refresh!), repeats: true, block: { (_) in
            self.getStatus(self.appliedFilter)
        })
    }
    
    public func stopBackgroundThread() {
        if timer.isValid {
            timer.invalidate()
            URLSession.shared.invalidateAndCancel()
            Utils.shared.log(msgType: .StoppedClient, type: .INFO)
        }
    }
    
    public func timerIsValid() -> Bool {
        if let timer = timer {
            return timer.isValid
        }
        return false
    }
    
    @objc func toggle() {
        if timerIsValid() {
            stopBackgroundThread()
        } else {
            startBackgroundThread()
        }
    }
    
    public func getStatus(_ filter: Filter = .ALL) {
        appliedFilter = filter
        var req = URLRequest(url: URL(string: baseURL)!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
        req.setValue("Basic \(loginEncoded)", forHTTPHeaderField: "Authorization")
        
        let reqBody = RPCRequest(method: "torrent-get", arguments: ArgumentsReq(fields: [
            "id",
            "name",
            "percentDone",
            "status",
            "totalSize",
            "eta",
            "rateDownload",
            ]))
        let encoder = JSONEncoder()
        
        guard let dataEncoded = try? encoder.encode(reqBody) else {
            print("Error encoding data")
            return
        }
        req.httpBody = dataEncoded
        
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            URLSession.shared.dataTask(with: req) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.delegate.rpcDidGotStatusCode(.ServerNotFound)
                    return
                }
                
                guard let res = response as? HTTPURLResponse else {
                    print("No response received")
                    self.delegate.rpcDidGotStatusCode(.ServerNotFound)
                    return
                }
                
                if self.handleResCode(statusCode: res.statusCode) == -1 {
                    self.delegate.rpcDidGotStatusCode(.ServerNotFound)
                    print("Error!")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    self.delegate.rpcDidGotTorrentStatus([])
                    return
                }
                
                let decoder = JSONDecoder()
                guard let resDecoded = try? decoder.decode(RPCResponse.self, from: data) else {
                    let htmlResponse = String(data: data, encoding: .utf8)!
                    let startIndex = htmlResponse.range(of: "X-Transmission-Session-Id:")?.upperBound
                    let endIndex = htmlResponse.range(of: "</code>")?.lowerBound
                    let diff = startIndex!..<endIndex!
                    self.sessionID = String(htmlResponse[diff])
                    Utils.shared.log(msgType: .NeedSessionId, type: .INFO)
                    self.getStatus(filter)
                    return
                }
                
                if let torrents = resDecoded.arguments!.torrents {
                    self.applyFilter(filter, list: torrents)
                    self.delegate.rpcDidGotNumberOfItems(self.countItems(torrents))
                }
            }.resume()
        }
    }
    
    private func applyFilter(_ filering: Filter, list: [Torrent]) {
        var filtered: [Torrent] = []
        
        switch filering {
        case .ALL:
            filtered = list
        case .DOWNLOAD:
            filtered = list.filter { (torrent) -> Bool in
                return [3, 4].contains(torrent.status!)
            }
        case .PAUSED:
            filtered = list.filter { (torrent) -> Bool in
                return torrent.status! == 0
            }
        case .SEEDING:
            filtered = list.filter { (torrent) -> Bool in
                return [5, 6].contains(torrent.status!)
            }
        case .DONE:
            filtered = list.filter { (torrent) -> Bool in
                return torrent.percentDone == 1.0
            }
        }
        Utils.shared.log(msgType: .RequestedTorrent, type: .INFO)
        self.delegate.rpcDidGotTorrentStatus(filtered)
    }

    public func addTorrentToTransmit(magnetLink: String) {
        var req = URLRequest(url: URL(string: baseURL)!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
        req.setValue("Basic \(loginEncoded)", forHTTPHeaderField: "Authorization")
        
        let reqBody = RPCRequest(method: "torrent-add", arguments: ArgumentsReq(filename: magnetLink))
        let encoder = JSONEncoder()
        
        guard let dataEncoded = try? encoder.encode(reqBody) else {
            print("Error encoding data")
            return
        }
        req.httpBody = dataEncoded
        
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            URLSession.shared.dataTask(with: req) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.delegate.rpcDidGotStatusCode(.ServerNotFound)
                    return
                }
                
                guard let res = response as? HTTPURLResponse else {
                    print("No response received")
                    self.delegate.rpcDidGotStatusCode(.ServerNotFound)
                    return
                }
                
                if self.handleResCode(statusCode: res.statusCode) == -1 {
                    self.delegate.rpcDidGotStatusCode(.ServerNotFound)
                    print("Error!")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    self.delegate.rpcDidGotTorrentStatus([])
                    return
                }
                
                Utils.shared.log(msgType: .TorrentAdded, type: .INFO)
                
                let decoder = JSONDecoder()
                guard let _ = try? decoder.decode(RPCResponse.self, from: data) else {
                    let htmlResponse = String(data: data, encoding: .utf8)!
                    let startIndex = htmlResponse.range(of: "X-Transmission-Session-Id:")?.upperBound
                    let endIndex = htmlResponse.range(of: "</code>")?.lowerBound
                    let diff = startIndex!..<endIndex!
                    self.sessionID = String(htmlResponse[diff])
                    Utils.shared.log(msgType: .NeedSessionId, type: .INFO)
                    self.addTorrentToTransmit(magnetLink: magnetLink)
                    return
                }
                self.getStatus()
            }.resume()
        }
    }

    public func torrentToggle(id: Int, needStart: Bool) {
        var req = URLRequest(url: URL(string: baseURL)!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
        req.setValue("Basic \(loginEncoded)", forHTTPHeaderField: "Authorization")
        
        var method = "torrent-start"
        if !needStart {
            method = "torrent-stop"
        }
        
        let reqBody = RPCRequest(method: method, arguments: ArgumentsReq(ids: id))
        let encoder = JSONEncoder()
        
        guard let dataEncoded = try? encoder.encode(reqBody) else {
            print("Error encoding data")
            return
        }
        req.httpBody = dataEncoded
        
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            URLSession.shared.dataTask(with: req) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.delegate.rpcDidGotStatusCode(.ServerNotFound)
                    return
                }
                
                guard let res = response as? HTTPURLResponse else {
                    print("No response received")
                    self.delegate.rpcDidGotStatusCode(.ServerNotFound)
                    return
                }
                
                if self.handleResCode(statusCode: res.statusCode) == -1 {
                    self.delegate.rpcDidGotStatusCode(.ServerNotFound)
                    print("Error!")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    self.delegate.rpcDidGotTorrentStatus([])
                    return
                }
                
                Utils.shared.log(msgType: .TorrentPaused, type: .INFO)
                
                let decoder = JSONDecoder()
                guard let _ = try? decoder.decode(RPCResponse.self, from: data) else {
                    let htmlResponse = String(data: data, encoding: .utf8)!
                    let startIndex = htmlResponse.range(of: "X-Transmission-Session-Id:")?.upperBound
                    let endIndex = htmlResponse.range(of: "</code>")?.lowerBound
                    let diff = startIndex!..<endIndex!
                    self.sessionID = String(htmlResponse[diff])
                    Utils.shared.log(msgType: .NeedSessionId, type: .INFO)
                    self.torrentToggle(id: id, needStart: needStart)
                    return
                }
                self.getStatus()
            }.resume()
        }
    }
    
    private func handleResCode(statusCode: Int) -> Int {
        if statusCode == 404 {
            // Server not found
            Utils.shared.log("404 - Server Not Found", msgType: .GotStatusCode, type: .ERROR)
            self.delegate.rpcDidGotStatusCode(.ServerNotFound)
            return -1
        } else if statusCode == 502 {
            // Bad Gateway
            Utils.shared.log("502 - Bad Gateway", msgType: .GotStatusCode, type: .ERROR)
            self.delegate.rpcDidGotStatusCode(.BadGateway)
            return -1
        } else if statusCode == 409 {
            // Conflict
            Utils.shared.log("409 - Conflict (Session-Id)", msgType: .GotStatusCode, type: .DEBUG)
            self.delegate.rpcDidGotStatusCode(.Conflict)
            return 1
        } else if statusCode == 200 {
            // Success
            Utils.shared.log("200 - Success", msgType: .GotStatusCode, type: .DEBUG)
            self.delegate.rpcDidGotStatusCode(.Success)
            return 1
        }
        return -1
    }
    
    private func countItems(_ torrents: [Torrent]) -> [Int] {
        return [
            // ALL
            torrents.count,
            // DOWNLOADING
            torrents.filter({ [3, 4].contains($0.status!) }).count,
            // SEEDING
            torrents.filter({ [5, 6].contains($0.status!) }).count,
            // PAUSED
            torrents.filter({ $0.status == 0 }).count,
            // DONE
            torrents.filter({ $0.percentDone == 1.0 }).count,
        ]
    }

}

@objc extension RPCCLient {
    
    private func updateUserDefaults() {
        self.getUserDefaults()
    }
    
    private func didGotMagnetLink(_ noti: Notification) {
        if let userInfo = noti.userInfo {
            if let magnet = userInfo["magnet"] as? String {
                addTorrentToTransmit(magnetLink: magnet)
            }
        }
    }
    
}
