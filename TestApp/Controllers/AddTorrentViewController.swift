//
//  AddTorrentViewController.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/5/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class AddTorrentViewController: UITableViewController, UITextFieldDelegate {
    
    let list = ["Magnet Link", "Download Folder"]
    let placeholder = ["Insert here", "/Users/lorenzoferrante/Plex/Movies"]
    
    var magnetLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Torrent"
        self.navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        
        setUpTabvleView()
    }
    
    private func setUpTabvleView() {
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
        
        cell.textField.delegate = self
        cell.textField.tag = indexPath.row
        
        if indexPath.row == 0 {
            cell.textField.text = "magnet:?xt=urn:btih:CE6D2A6BBC439A8F6B94B23BA63B04164400FE3B&dn=Parasite&tr=http://track.one:1234/announce&tr=udp://track.two:80"
        }
        
        cell.label.text = list[indexPath.row]
        cell.textField.placeholder = placeholder[indexPath.row]
        
        return cell
    }
    
}

@objc extension AddTorrentViewController {
    func done() {
        if let magnet = magnetLink {
            NotificationCenter.default.post(name: .didGotMagnetLink, object: nil, userInfo: ["magnet": magnet])
        }
        self.dismiss(animated: true) {}
    }
    
    func cancel() {
        self.dismiss(animated: true) {}
    }
}

extension AddTorrentViewController {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 0 {
            if let text = textField.text {
                magnetLink = text
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
