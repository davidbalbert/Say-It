//
//  StatusMenuDelegate.swift
//  Say It
//
//  Created by David Albert on 3/7/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class StatusMenuDelegate: NSObject, NSMenuDelegate {
    @IBOutlet var transcriptMenuItem: NSMenuItem!

    func menuNeedsUpdate(_ menu: NSMenu) {
        if NSEvent.modifierFlags.contains(.option) {
            transcriptMenuItem.isHidden = false
        } else {
            transcriptMenuItem.isHidden = true
        }
    }
}
