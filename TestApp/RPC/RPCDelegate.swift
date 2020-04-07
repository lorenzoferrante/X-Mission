//
//  RPCDelegate.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/4/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import Foundation

public enum RESCODE: Int {
    case ServerNotFound
    case BadGateway
    case Success
    case Conflict
}

public protocol RPCClienteDelegate {
    func rpcDidGotTorrentStatus(_ torrents: [Torrent])
    func rpcDidGotStatusCode(_ code: RESCODE)
    func rpcDidGotNumberOfItems(_ items: [Int])
}
extension RPCClienteDelegate {
    func rpcDidGotTorrentStatus(_ torrents: [Torrent]) {}
    func rpcDidGotStatusCode(_ code: RESCODE) {}
    func rpcDidGotNumberOfItems(_ items: [Int]) {}
}
