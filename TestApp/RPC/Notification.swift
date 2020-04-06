//
//  Notification.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/5/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didGotMagnetLink = Notification.Name("didGotMagnetLink")
    static let didChangeFilter = Notification.Name("didChangeFilter")
    static let didGotNewLog = Notification.Name("didGotNewLog")
    static let needOpenLogView = Notification.Name("needOpenLogView")
    static let needOpenSettingsView = Notification.Name("needOpenSettingsView")
    static let userDefaultNeedUpdate = Notification.Name("userDefaultNeedUpdate")
}
