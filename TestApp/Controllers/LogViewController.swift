//
//  LogViewController.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/6/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(didGotNewLog), name: .didGotNewLog, object: nil)
        
        self.title = "Logs"
        self.navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        
        setUpTextView()
    }
    
    private func setUpTextView() {
        self.textView.font = roundedFont(ofSize: .body, weight: .medium)
        getUserLogs()
    }
    
    private func getUserLogs() {
        if let logs = UserDefaults.standard.value(forKey: Utils.LOG_KEY) {
            DispatchQueue.main.async {
                self.textView.text = Utils.shared.formatLogs((logs as? String)!)
                self.textView.reloadInputViews()
            }
        }
    }
    
    private func roundedFont(ofSize style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        // Will be SF Compact or standard SF in case of failure.
        let fontSize = UIFont.preferredFont(forTextStyle: style).pointSize
        if let descriptor = UIFont.systemFont(ofSize: fontSize, weight: weight).fontDescriptor.withDesign(.monospaced) {
            return UIFont(descriptor: descriptor, size: fontSize)
        } else {
            return UIFont.preferredFont(forTextStyle: style)
        }
    }

}

@objc extension LogViewController {
    
    func done() {
        self.dismiss(animated: true) {}
    }
    
    private func didGotNewLog() {
        self.getUserLogs()
    }
    
}
