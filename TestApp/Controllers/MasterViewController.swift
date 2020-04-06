//
//  MasterViewController.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/4/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import Foundation
import UIKit

class MasterViewController: UITableViewController {
    
    let menuFirst = ["All Torrents", "Downloading", "Seeding", "Paused", "Done"]
    let menuSecond = ["Settings", "Logs"]
    let menuIconsFirst = ["list.bullet", "arrow.down", "arrow.up", "pause.circle.fill", "doc.fill"]
    let menuIconsSecond = ["gear", "exclamationmark.bubble"]
    
    var deatailTitle = "All Torrents"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Mission"
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        setUpTableView()
    }
    
    private func setUpTableView() {
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(MenuTableViewCell<MenuListView>.self, forCellReuseIdentifier: "MenuCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return menuFirst.count
        }
        return menuSecond.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell<MenuListView>
        
        var menu: [String] = []
        var menuIcon: [String] = []
        
        if indexPath.section == 0 {
            menu = menuFirst
            menuIcon = menuIconsFirst
        } else {
            menu = menuSecond
            menuIcon = menuIconsSecond
        }
        
        let menuItem = MenuListView(menuIcon: menuIcon[indexPath.row], menuLabel: menu[indexPath.row])
        cell.host(view: menuItem, parent: self)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            switch indexPath.row {
            case 0:
                RPCCLient.shared.getStatus(.ALL)
                deatailTitle = "All Torrents"
            case 1:
                RPCCLient.shared.getStatus(.DOWNLOAD)
                deatailTitle = "Downloading"
            case 2:
                RPCCLient.shared.getStatus(.SEEDING)
                deatailTitle = "Seeding"
            case 3:
                RPCCLient.shared.getStatus(.PAUSED)
                deatailTitle = "Paused"
            case 4:
                RPCCLient.shared.getStatus(.DONE)
                deatailTitle = "Done"
            default:
                RPCCLient.shared.getStatus(.ALL)
                deatailTitle = "All Torrents"
            }
            
            NotificationCenter.default.post(name: .didChangeFilter, object: nil, userInfo: ["title": deatailTitle])
        }
        
        if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                NotificationCenter.default.post(name: .needOpenSettingsView, object: nil)
            case 1:
                NotificationCenter.default.post(name: .needOpenLogView, object: nil)
            default:
                break
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
