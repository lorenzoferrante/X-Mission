//
//  Specs.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/4/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import Foundation
import SwiftUI

public enum Filter {
    case ALL
    case DOWNLOAD
    case SEEDING
    case PAUSED
    case DONE
}

// MARK: - Status
public enum TR_STATUS: Int {
    case TR_STATUS_STOPPED = 0 /* Torrent is stopped */
    case TR_STATUS_CHECK_WAIT = 1 /* Queued to check files */
    case TR_STATUS_CHECK = 2 /* Checking files */
    case TR_STATUS_DOWNLOAD_WAIT = 3 /* Queued to download */
    case TR_STATUS_DOWNLOAD = 4 /* Downloading */
    case TR_STATUS_SEED_WAIT = 5 /* Queued to seed */
    case TR_STATUS_SEED = 6 /* Seeding */
    
    func toString() -> String {
        switch self {
        case .TR_STATUS_STOPPED:  /* Torrent is stopped */
            return "Paused"
        case .TR_STATUS_CHECK_WAIT: /* Queued to check files */
            return "Queued to check files */"
        case .TR_STATUS_CHECK: /* Checking files */
            return "Checking files"
        case .TR_STATUS_DOWNLOAD_WAIT: /* Queued to download */
            return "Queued to download"
        case .TR_STATUS_DOWNLOAD: /* Downloading */
            return "Downloading"
        case .TR_STATUS_SEED_WAIT: /* Queued to seed */
            return "Queued to seed"
        case .TR_STATUS_SEED: /* Seeding */
            return "Seeding"
        }
    }
}

// MARK:- Request
public struct ArgumentsReq: Codable {
    var fields: [String]?
    var filename: String?
    var ids: Int?
}
public struct RPCRequest: Codable {
    var method: String
    var arguments: ArgumentsReq?
}

// MARK:- Response
public struct Torrent: Codable {
    var id: Int?
    var name: String?
    var percentDone: Double?
    var status: Int?
    var totalSize: Int?
    var eta: Int?
    var rateDownload: Int?
}
public struct ArgumentsRes: Codable {
    var torrents: [Torrent]?
}
public struct RPCResponse: Codable {
    var arguments: ArgumentsRes?
    var result: String?
}
