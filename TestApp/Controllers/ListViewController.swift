//
//  ListViewController.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/4/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class ListViewController: UITableViewController, RPCClienteDelegate {
    
    var needDisplayError: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var torrentList: [Torrent]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        RPCCLient.shared.delegate = self
        
        #if !targetEnvironment(macCatalyst)
        
        let stopPlayButton = UIBarButtonItem(
            barButtonSystemItem: RPCCLient.shared.timerIsValid() ? .play : .pause,
            target: self,
            action: #selector(toogle))
        let addTorrentButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(self.showAddView))
        
        navigationItem.rightBarButtonItems = [stopPlayButton, addTorrentButton]
        #endif
        
        self.title = "All Torrents"
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTitle(_:)), name: .didChangeFilter, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLogsView), name: .needOpenLogView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSettingsView), name: .needOpenSettingsView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeOnBoard), name: .needCloseOnBoard, object: nil)
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        let onBoardView = UIHostingController(rootView: OnBoardView())
        self.present(onBoardView, animated: true)
        
        setUpTableView()
    }
    
    private func setUpTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(HostingTorrent<TorrentView>.self, forCellReuseIdentifier: "torrentCell")
        tableView.register(ErrorTableViewCell<ErrorCell>.self, forCellReuseIdentifier: "errorCell")
        tableView.register(EmptyTableViewCell<EmptyCell>.self, forCellReuseIdentifier: "emptyCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if needDisplayError {
            return 1
        }
        
        if torrentList != nil {
            return torrentList!.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if needDisplayError {
            let cell = tableView.dequeueReusableCell(withIdentifier: "errorCell") as! ErrorTableViewCell<ErrorCell>
            cell.host(parent: self)
            return cell
        }
        
        if let list = torrentList {
            let cell = tableView.dequeueReusableCell(withIdentifier: "torrentCell") as! HostingTorrent<TorrentView>
            cell.host(parent: self, obj: TorrentObserved(torrentData: list[indexPath.row]))
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell") as! EmptyTableViewCell<EmptyCell>
        cell.host(parent: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ListViewController {
    
    func rpcDidGotTorrentStatus(_ torrents: [Torrent]) {
        self.torrentList = torrents
        print(torrents)
    }
    
    func rpcDidGotStatusCode(_ code: RESCODE) {
        if [RESCODE.Success, RESCODE.Conflict].contains(code) {
            needDisplayError = false
        } else {
            needDisplayError = true
        }
    }
    
    func rpcDidGotNumberOfItems(_ items: [Int]) {
        NotificationCenter.default.post(name: .didGotItemsNumber, object: nil, userInfo: ["items": items])
    }
    
}

@objc extension ListViewController {
    private func toogle() {
        RPCCLient.shared.toggle()
        
        let stopPlayButton = UIBarButtonItem(
            barButtonSystemItem: RPCCLient.shared.timerIsValid() ? .play : .pause,
            target: self,
            action: #selector(toogle))
        navigationItem.setRightBarButton(stopPlayButton, animated: true)
    }
    
    private func showAddView() {
        self.performSegue(withIdentifier: "ShowAddView", sender: self)
    }
    
    private func showLogsView() {
        self.performSegue(withIdentifier: "ShowLogs", sender: self)
    }
    
    private func showSettingsView() {
        self.performSegue(withIdentifier: "ShowSettings", sender: self)
    }
    
    private func didChangeTitle(_ noti: Notification) {
        if let userInfo = noti.userInfo {
            if let title = userInfo["title"] as? String {
                DispatchQueue.main.async {
                    self.title = title
                }
            }
        }
    }
    
    private func closeOnBoard() {
        self.dismiss(animated: true, completion: nil)
    }
}
