//
//  StatusMenuDelegate.swift
//  Say It
//
//  Created by David Albert on 3/7/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, NSMenuDelegate {
    @IBOutlet var transcriptMenuItem: NSMenuItem!
    @IBOutlet var stopSpeakingMenuItem: NSMenuItem!
    @IBOutlet var menu: NSMenu! {
        didSet {
            self.statusItem.menu = menu
            menu.delegate = self
        }
    }

    let statusItem: NSStatusItem
    let statusIcon = NSImage(named: "StatusIcon")
    let playingIcon = NSImage(named: "StatusIcon-playing")

    var beginHandlerId: UUID?
    var completionHandlerId: UUID?

    override init() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        self.statusItem.button?.image = statusIcon

        super.init()
    }

    func highlightMenu() {
        self.statusItem.button?.highlight(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.statusItem.button?.highlight(false)
        }
    }

    func registerCallbacks(_ speaker: Speaker) {
        beginHandlerId = speaker.addBeginHandler { [weak self] in
            self?.statusItem.button?.image = self?.playingIcon
            self?.stopSpeakingMenuItem.isEnabled = true
        }

        completionHandlerId = speaker.addCompletionHandler { [weak self] in
            self?.statusItem.button?.image = self?.statusIcon
            self?.stopSpeakingMenuItem.isEnabled = false
        }
    }

    deinit {
        if let beginHandlerId = beginHandlerId {
            appDelegate.speaker.removeBeginHandler(beginHandlerId)
        }

        if let completionHandlerId = completionHandlerId {
            appDelegate.speaker.removeCompletionHandler(completionHandlerId)
        }
    }


    func menuNeedsUpdate(_ menu: NSMenu) {
        if NSEvent.modifierFlags.contains(.option) {
            transcriptMenuItem.isHidden = false
        } else {
            transcriptMenuItem.isHidden = true
        }
    }
}
