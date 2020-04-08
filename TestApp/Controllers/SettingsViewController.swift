//
//  SettingsViewController.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/6/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    
    let sectionOne = ["Server Address", "Port", "Path", "Username", "Password"]
    var placeholderOne = ["Server Address", "Port", "Path", "Username", "Password"]
    
    let sectionTwo = ["Refresh Rate"]
    var placeholderTwo = ["3"]
    let footerTwo = "Refresh Rate (in seconds) indicates how often an update from the server will be requested (recommended values are 3-5 seconds)"
    
    let sectionThree = ["Download Directory"]
    var placeholderThree = ["define this var"]
    let footerThree = "Download Directory indicates the download location in you server"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        self.navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        
        getUserDefaultsValue()
        setUpTabvleView()
    }
    
    private func setUpTabvleView() {
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
    }
    
    private func getUserDefaultsValue() {
        placeholderOne = [
            UserDefaults.standard.value(forKey: Utils.IP) as! String,
            UserDefaults.standard.value(forKey: Utils.PORT) as! String,
            UserDefaults.standard.value(forKey: Utils.PATH) as! String,
            UserDefaults.standard.value(forKey: Utils.USER) as! String,
            UserDefaults.standard.value(forKey: Utils.PWD) as! String
        ]
        
        placeholderTwo = [
            String(UserDefaults.standard.value(forKey: Utils.REFRESH) as! Int)
        ]
        
        placeholderThree = [
            UserDefaults.standard.value(forKey: Utils.DOWNLOADDIR) as! String
        ]
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sectionOne.count
        } else if section == 1 {
            return sectionTwo.count
        } else if section == 2 {
            return sectionThree.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
        
        var section: [String] = []
        var placeholder: [String] = []
        
        if indexPath.section == 0 {
            section = sectionOne
            placeholder = placeholderOne
        }
        if indexPath.section == 1 {
            section = sectionTwo
            placeholder = placeholderTwo
        }
        if indexPath.section == 2 {
            section = sectionThree
            placeholder = placeholderThree
        }
        
        cell.label.text = section[indexPath.row]
        cell.textField.placeholder = placeholder[indexPath.row]
        cell.textField.delegate = self
        cell.textField.tag = ((indexPath.row + sectionOne.count) * indexPath.section) + indexPath.row
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return footerTwo
        }
        
        if section == 2 {
            return footerThree
        }
        
        return nil
    }

}

extension SettingsViewController {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let text = textField.text else {
            return true
        }
        
        if text == "" { return true }
        
        switch textField.tag {
        case 0: // IP
            Utils.shared.didSetUserDefault(Utils.IP, val: text)
        case 1: // PORT
            Utils.shared.didSetUserDefault(Utils.PORT, val: text)
        case 2: // PATH
            Utils.shared.didSetUserDefault(Utils.PATH, val: text)
        case 3: // USER
            Utils.shared.didSetUserDefault(Utils.USER, val: text)
        case 4: // PWD
            Utils.shared.didSetUserDefault(Utils.PWD, val: text)
        case 5: // REFRESH
            if let refresh = Int(text) {
                Utils.shared.didSetUserDefault(Utils.REFRESH, val: refresh)
            }
        default:
            break
        }
        
        NotificationCenter.default.post(name: .userDefaultNeedUpdate, object: nil)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

@objc extension SettingsViewController {
    
    func done() {
        self.dismiss(animated: true) {}
    }
    
}
