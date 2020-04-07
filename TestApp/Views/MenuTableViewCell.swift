//
//  MenuTableViewCell.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/5/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class MenuTableViewCell<Content: View>: UITableViewCell {
    private var controller: UIHostingController<MenuListView>?
    
    func host(parent: UIViewController, icon: String, label: String, items: ItemsObserver) {
        if let controller = controller {
            let menuView = MenuListView(menuIcon: icon, menuLabel: label, items: items)
            controller.rootView = menuView
            controller.view.layoutIfNeeded()
        } else {
            let menuView = MenuListView(menuIcon: icon, menuLabel: label, items: items)
            let swiftUICellViewController = UIHostingController(rootView: menuView)
            controller = swiftUICellViewController
            swiftUICellViewController.view.backgroundColor = .clear

            layoutIfNeeded()

            parent.addChild(swiftUICellViewController)
            contentView.addSubview(swiftUICellViewController.view)
            controller?.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraint(NSLayoutConstraint(item: swiftUICellViewController.view!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
            contentView.addConstraint(NSLayoutConstraint(item: swiftUICellViewController.view!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
            contentView.addConstraint(NSLayoutConstraint(item: swiftUICellViewController.view!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
            contentView.addConstraint(NSLayoutConstraint(item: swiftUICellViewController.view!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))

            swiftUICellViewController.didMove(toParent: parent)
            swiftUICellViewController.view.layoutIfNeeded()
        }
    }

}
