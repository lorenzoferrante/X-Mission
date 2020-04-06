//
//  SceneDelegate.swift
//  TestApp
//
//  Created by Lorenzo Ferrante on 4/4/20.
//  Copyright © 2020 Lorenzo Ferrante. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    #if targetEnvironment(macCatalyst)
    private let playStopToolbarIdentifier = NSToolbarItem.Identifier(rawValue: "PlayStopButton")
    private let addToolbarIdentifier = NSToolbarItem.Identifier(rawValue: "AddButton")
    #endif

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)
        let toolbar = createToolbar()
        
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = toolbar
        }
        #endif
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        RPCCLient.shared.stopBackgroundThread()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        RPCCLient.shared.startBackgroundThread()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        RPCCLient.shared.startBackgroundThread()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        RPCCLient.shared.stopBackgroundThread()
    }
    
    #if targetEnvironment(macCatalyst)
    private func createToolbar() -> NSToolbar {
        let toolbar = NSToolbar(identifier: "CatalystToolbar")
        toolbar.delegate = self
        return toolbar
    }
    #endif
}

#if targetEnvironment(macCatalyst)
extension SceneDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .flexibleSpace,
            addToolbarIdentifier,
            playStopToolbarIdentifier,
        ]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if (itemIdentifier == playStopToolbarIdentifier) {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: RPCCLient.shared.timerIsValid() ? .play : .pause, target: self, action: #selector(self.toggle))
            let button = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: barButtonItem)
            return button
        } else if (itemIdentifier == addToolbarIdentifier) {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTorrent))
            let button = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: barButtonItem)
            return button
        }
        return nil
    }
}

@objc extension SceneDelegate {
    
    func addTorrent() {
        let splitVC = window!.rootViewController as! UISplitViewController
        if let navVC = splitVC.viewControllers[1] as? UINavigationController {
            if let listVC = navVC.viewControllers[0] as? ListViewController {
                listVC.performSegue(withIdentifier: "ShowAddView", sender: self)
            }
        }
    }
    
    func toggle() {
        RPCCLient.shared.toggle()
        window?.windowScene?.titlebar!.toolbar?.removeItem(at: 2)
        window?.windowScene?.titlebar!.toolbar?.insertItem(withItemIdentifier: playStopToolbarIdentifier, at: 2)
    }
    
}

#endif



